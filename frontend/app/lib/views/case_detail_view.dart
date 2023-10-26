// ignore_for_file: lines_longer_than_80_chars

import "package:aw40_hub_frontend/exceptions/app_exception.dart";
import "package:aw40_hub_frontend/models/models.dart";
import "package:aw40_hub_frontend/providers/providers.dart";
import "package:aw40_hub_frontend/services/services.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:aw40_hub_frontend/utils/extensions.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";

class CaseDetailView extends StatelessWidget {
  const CaseDetailView({
    required this.caseModel,
    required this.onClose,
    super.key,
  });

  final CaseModel caseModel;
  final void Function() onClose;

  @override
  Widget build(BuildContext context) {
    return EnvironmentService().isMobilePlatform
        ? MobileCaseDetailView(
            caseModel: caseModel,
            onDelete: () async => _onDeleteButtonPress(
              context,
              Provider.of<AuthProvider>(context, listen: false).loggedInUser,
              caseModel.id,
            ),
          )
        : DesktopCaseDetailView(
            caseModel: caseModel,
            onClose: onClose,
            onDelete: () async => _onDeleteButtonPress(
              context,
              Provider.of<AuthProvider>(context, listen: false).loggedInUser,
              caseModel.id,
            ),
          );
  }

  static Future<bool?> _showConfirmDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tr("cases.details.dialog.title")),
          content: Text(tr("cases.details.dialog.description")),
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
    String caseModelId,
  ) async {
    final caseProvider = Provider.of<CaseProvider>(
      context,
      listen: false,
    );

    await _showConfirmDeleteDialog(context).then((bool? dialogResult) async {
      final ScaffoldMessengerState scaffoldMessengerState =
          ScaffoldMessenger.of(context);
      if (dialogResult == null || !dialogResult) return;
      final bool result = await caseProvider.deleteCase(caseModelId);
      final String message = result
          ? tr("cases.details.deleteCaseSuccessMessage")
          : tr("cases.details.deleteCaseErrorMessage");
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

class DesktopCaseDetailView extends StatefulWidget {
  const DesktopCaseDetailView({
    required this.caseModel,
    required this.onClose,
    required this.onDelete,
    super.key,
  });

  final CaseModel caseModel;
  final void Function() onClose;
  final void Function() onDelete;

  @override
  State<DesktopCaseDetailView> createState() => _DesktopCaseDetailViewState();
}

class _DesktopCaseDetailViewState extends State<DesktopCaseDetailView> {
  bool isInEditState = false;
  // TODO get value from caseModel
  DateTime dateTime = DateTime(
    2023,
    10,
    26,
    14,
    30,
  );

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final List<String> attributes = [
      tr("general.id"),
      tr("general.status"),
      tr("general.occasion"),
      tr("general.date"),
      tr("general.milage"),
      tr("general.customerId"),
      tr("general.vehicleVin"),
      tr("general.workshopId"),
    ];
    final List<String> values = [
      widget.caseModel.id,
      tr("cases.details.status.${widget.caseModel.status.name}"),
      tr("cases.details.occasion.${widget.caseModel.occasion.name}"),
      widget.caseModel.timestamp.toGermanDateString(),
      widget.caseModel.milage.toString(),
      widget.caseModel.customerId,
      widget.caseModel.vehicleVin,
      widget.caseModel.workshopId,
    ];

    final formKey = GlobalKey<FormState>();
    final TextEditingController statusController = TextEditingController();
    final TextEditingController occasionController = TextEditingController();
    final TextEditingController timestampController = TextEditingController();
    final TextEditingController milageController = TextEditingController();

    return SizedBox.expand(
      child: Card(
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AppBar(
                backgroundColor: const Color.fromARGB(0, 0, 0, 0),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: widget.onClose,
                ),
                title: Text(
                  tr("cases.details.headline"),
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      if (!isInEditState) {
                        setState(() => isInEditState = true);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: widget.onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Table(
                columnWidths: const {0: IntrinsicColumnWidth()},
                children: List.generate(
                  attributes.length,
                  (i) => TableRow(
                    children: !isInEditState
                        ? [
                            const SizedBox(height: 32),
                            Text(attributes[i]),
                            Text(values[i]),
                          ]
                        : [
                            const SizedBox(height: 32),
                            Text(attributes[i]),
                            if (i < 1 || i > 4)
                              Text(values[i])
                            else if (i == 1)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FormField(
                                    initialValue: widget.caseModel.status,
                                    builder: (FormFieldState<dynamic> field) {
                                      return SegmentedButton(
                                        emptySelectionAllowed:
                                            true, // TODO false?
                                        segments: <ButtonSegment<CaseStatus>>[
                                          ButtonSegment<CaseStatus>(
                                            value: CaseStatus.open,
                                            label: Text(
                                              tr("cases.details.status.open"),
                                            ),
                                          ),
                                          ButtonSegment<CaseStatus>(
                                            value: CaseStatus.closed,
                                            label: Text(
                                              tr("cases.details.status.closed"),
                                            ),
                                          ),
                                        ],
                                        selected: {field.value},
                                      );
                                    },
                                  ),
                                ],
                              )
                            else if (i == 2)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FormField(
                                    initialValue: widget.caseModel.occasion,
                                    builder: (FormFieldState<dynamic> field) {
                                      return SegmentedButton(
                                        emptySelectionAllowed:
                                            true, // TODO false?
                                        segments: <ButtonSegment<CaseOccasion>>[
                                          ButtonSegment<CaseOccasion>(
                                            value: CaseOccasion.service_routine,
                                            label: Text(
                                              tr("cases.occasions.service"),
                                            ),
                                          ),
                                          ButtonSegment<CaseOccasion>(
                                            value: CaseOccasion.problem_defect,
                                            label: Text(
                                              tr("cases.occasions.problem"),
                                            ),
                                          ),
                                        ],
                                        selected: {field.value},
                                      );
                                    },
                                  ),
                                ],
                              )
                            else if (i == 3)
                              TextFormField(
                                readOnly:
                                    true, // Damit das Feld nicht bearbeitbar ist
                                controller: TextEditingController(
                                  text:
                                      "${dateTime.day}.${dateTime.month}.${dateTime.year} ${dateTime.hour}:${dateTime.minute}",
                                ),
                                onTap: () async {
                                  DateTime? selectedDateTime =
                                      await pickDateTime();
                                  if (selectedDateTime != null) {
                                    setState(() {
                                      dateTime = selectedDateTime;
                                    });
                                  }
                                },
                              )
                            else if (i == 4)
                              TextFormField(
                                controller: milageController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return tr("general.obligatoryField");
                                  }
                                  return null;
                                },
                                onSaved: (customerId) {
                                  if (customerId == null) {
                                    throw AppException(
                                      exceptionType:
                                          ExceptionType.unexpectedNullValue,
                                      exceptionMessage:
                                          "Milage was null, validation failed.",
                                    );
                                  }
                                  if (customerId.isEmpty) {
                                    throw AppException(
                                      exceptionType:
                                          ExceptionType.unexpectedNullValue,
                                      exceptionMessage:
                                          "Milage was empty, validation failed.",
                                    );
                                  }
                                },
                              )
                          ],
                  ),
                ),
              ),
              if (isInEditState)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(),
                      ),
                      TextButton(
                        onPressed: () => setState(() => isInEditState = false),
                        child: Text(tr("general.cancel")),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO implement - save changes
                          setState(() => isInEditState = false);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        child: Text(
                          tr("general.saveChanges"),
                        ),
                      ),
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Future pickDateTime() async {
    DateTime? date = await pickDate();
    if (date == null) return;

    TimeOfDay? time = await pickTime();
    if (time == null) return;

    final selectedDateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);

    setState(() => dateTime = selectedDateTime);
  }

  Future<DateTime?> pickDate() => showDatePicker(
        context: context,
        initialDate: dateTime,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
      );

  Future<TimeOfDay?> pickTime() => showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(dateTime),
      );
}

class MobileCaseDetailView extends StatelessWidget {
  const MobileCaseDetailView({
    required this.caseModel,
    required this.onDelete,
    super.key,
  });

  final CaseModel caseModel;
  final void Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListTile(
      tileColor: theme.colorScheme.primaryContainer,
      title: const Text("Case Detail View"),
      subtitle: Text("ID: ${caseModel.id}"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
