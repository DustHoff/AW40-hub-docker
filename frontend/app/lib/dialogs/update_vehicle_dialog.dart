import "dart:async";

import "package:aw40_hub_frontend/dtos/vehicle_update_dto.dart";
import "package:aw40_hub_frontend/models/vehicle_model.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:routemaster/routemaster.dart";

class UpdateVehicleDialog extends StatefulWidget {
  const UpdateVehicleDialog({
    required this.vehicleModel,
    super.key,
  });

  final VehicleModel vehicleModel;

  @override
  State<UpdateVehicleDialog> createState() => _UpdateVehicleDialogState();
}

class _UpdateVehicleDialogState extends State<UpdateVehicleDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _vinController = TextEditingController();
  final TextEditingController _tsnController = TextEditingController();
  final TextEditingController _yearBuildController = TextEditingController();
  final title = tr("vehicles.actions.updateVehicle");

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    _vinController.text = widget.vehicleModel.vin ?? "";
    _tsnController.text = widget.vehicleModel.tsn ?? "";
    _yearBuildController.text = widget.vehicleModel.yearBuild.toString();

    return AlertDialog(
      title: Text(title),
      content: UpdateDialogForm(
        formKey: _formKey,
        vinController: _vinController,
        tsnController: _tsnController,
        yearBuildController: _yearBuildController,
        vehicleModel: widget.vehicleModel,
      ),
      actions: [
        TextButton(
          onPressed: () async => _onCancel(context),
          child: Text(
            tr("general.cancel"),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
        TextButton(
          onPressed: _submitUpdateVehicleForm,
          child: Text(tr("general.save")),
        ),
      ],
    );
  }

  void _submitUpdateVehicleForm() {
    final FormState? currentFormKeyState = _formKey.currentState;
    if (currentFormKeyState != null && currentFormKeyState.validate()) {
      currentFormKeyState.save();

      // TODO get updated values

      final VehicleUpdateDto vehicleUpdateDto = VehicleUpdateDto("", "", "", 0);
      unawaited(
        Routemaster.of(context).pop<VehicleUpdateDto>(vehicleUpdateDto),
      );
    }
  }

  Future<void> _onCancel(BuildContext context) async {
    await Routemaster.of(context).pop();
  }

  @override
  void dispose() {
    _vinController.dispose();
    _tsnController.dispose();
    _yearBuildController.dispose();
    super.dispose();
  }
}

class UpdateDialogForm extends StatelessWidget {
  const UpdateDialogForm({
    required this.formKey,
    required this.vinController,
    required this.tsnController,
    required this.yearBuildController,
    required this.vehicleModel,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController vinController;
  final TextEditingController tsnController;
  final TextEditingController yearBuildController;
  final VehicleModel vehicleModel;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [],
      ),
    );
  }
}
