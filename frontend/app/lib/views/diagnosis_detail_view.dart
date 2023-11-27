import "package:aw40_hub_frontend/models/models.dart";
import "package:aw40_hub_frontend/providers/providers.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class DiagnosisDetailView extends StatefulWidget {
  const DiagnosisDetailView({
    required this.diagnosisModel,
    super.key,
  });

  final DiagnosisModel diagnosisModel;

  @override
  State<DiagnosisDetailView> createState() => _DiagnosisDetailView();
}

class _DiagnosisDetailView extends State<DiagnosisDetailView> {
  final Map<DiagnosisStatus, IconData> diagnosisStatusIcons = {
    DiagnosisStatus.action_required: Icons.circle_notifications,
    DiagnosisStatus.finished: Icons.check_circle,
    DiagnosisStatus.failed: Icons.cancel,
    DiagnosisStatus.processing: Icons.circle,
    DiagnosisStatus.scheduled: Icons.circle,
  };

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return SizedBox.expand(
      child: Card(
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AppBar(
                backgroundColor: const Color.fromARGB(0, 0, 0, 0),
                title: Text(
                  tr("diagnoses.details.headline"),
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(color: colorScheme.onPrimaryContainer),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.delete_forever),
                    iconSize: 28,
                    style: IconButton.styleFrom(
                      foregroundColor: colorScheme.error,
                    ),
                    onPressed: () async => _onDeleteButtonPress(
                      context,
                      Provider.of<AuthProvider>(context, listen: false)
                          .loggedInUser,
                      widget.diagnosisModel.caseId,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Case ID
              Table(
                columnWidths: const {0: IntrinsicColumnWidth()},
                children: [
                  TableRow(
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        tr("general.case"),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        widget.diagnosisModel.caseId,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Current State
              Card(
                color: _getColorForDiagnosisStatus(
                  colorScheme,
                  widget.diagnosisModel.status,
                ),
                child: ListTile(
                  leading: Icon(
                    diagnosisStatusIcons[widget.diagnosisModel.status],
                  ),
                  title: Text(
                    tr("diagnoses.status.${widget.diagnosisModel.status.name}"),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _getColorComplementForDiagnosisStatus(
                        colorScheme,
                        widget.diagnosisModel.status,
                      ),
                    ),
                  ),
                  iconColor: _getColorComplementForDiagnosisStatus(
                    colorScheme,
                    widget.diagnosisModel.status,
                  ),
                  // TODO get widget.diagnosisModel.todos[0].instruction
                  /* subtitle: widget.diagnosisModel.status ==
                          DiagnosisStatus.action_required
                      ? Text(widget.diagnosisModel. ...)
                      : null,*/
                ),
              ),

              const SizedBox(height: 32),
              const Placeholder(),
            ],
          ),
        ),
      ),
    );
  }

  Color? _getColorForDiagnosisStatus(
    ColorScheme colorScheme,
    DiagnosisStatus diagnosisStatus,
  ) {
    final Map<DiagnosisStatus, Color> diagnosisStatusColor = {
      DiagnosisStatus.action_required: colorScheme.tertiary,
      DiagnosisStatus.finished: colorScheme.secondary,
      DiagnosisStatus.failed: colorScheme.error,
      DiagnosisStatus.processing: colorScheme.primary,
      DiagnosisStatus.scheduled: colorScheme.primary,
    };

    return diagnosisStatusColor[diagnosisStatus];
  }

  Color? _getColorComplementForDiagnosisStatus(
    ColorScheme colorScheme,
    DiagnosisStatus diagnosisStatus,
  ) {
    final Map<DiagnosisStatus, Color> diagnosisStatusColor = {
      DiagnosisStatus.action_required: colorScheme.onTertiary,
      DiagnosisStatus.finished: colorScheme.onSecondary,
      DiagnosisStatus.failed: colorScheme.onError,
      DiagnosisStatus.processing: colorScheme.onPrimary,
      DiagnosisStatus.scheduled: colorScheme.onPrimary,
    };

    return diagnosisStatusColor[diagnosisStatus];
  }

  static Future<bool?> _showConfirmDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tr("diagnoses.details.dialog.title")),
          content: Text(tr("diagnoses.details.dialog.description")),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(tr("general.cancel")),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(
                tr("general.delete"),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _onDeleteButtonPress(
    BuildContext context,
    LoggedInUserModel loggedInUserModel,
    String diagnosisModelCaseId,
  ) async {
    final diagnosisProvider = Provider.of<DiagnosisProvider>(
      context,
      listen: false,
    );

    await _showConfirmDeleteDialog(context).then((bool? dialogResult) async {
      final ScaffoldMessengerState scaffoldMessengerState =
          ScaffoldMessenger.of(context);
      if (dialogResult == null || !dialogResult) return;
      final bool deletionResult =
          await diagnosisProvider.deleteDiagnosis(diagnosisModelCaseId);
      final String message = deletionResult
          ? tr("diagnoses.details.deleteDiagnosisSuccessMessage")
          : tr("diagnoses.details.deleteDiagnosisErrorMessage");
      _showMessage(message, scaffoldMessengerState);
    });
  }

  static void _showMessage(String text, ScaffoldMessengerState state) {
    final SnackBar snackBar = SnackBar(
      content: Center(child: Text(text)),
    );
    state.showSnackBar(snackBar);
  }
}
