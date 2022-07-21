import 'package:epc_qr/qr_data.dart';
import 'package:epc_qr/view_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _formKey = GlobalKey<FormBuilderState>();
final _refKey = GlobalKey();
final _refTextKey = GlobalKey();

const _fieldPadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);

class EpcQrFormPage extends StatefulWidget {
  const EpcQrFormPage({Key? key}) : super(key: key);

  @override
  State<EpcQrFormPage> createState() => _EpcQrFormPageState();
}

class _EpcQrFormPageState extends State<EpcQrFormPage> {
  bool useRef = true; // TODO move this state into separate widget

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Payment Data'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.qr_code),
        onPressed: () => _showCode(context),
      ),
      body: FormBuilder(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8.0),
              const _NameInputField(),
              const _IbanInputField(),
              const _BicInputField(),
              const _AmountInputField(),
              const Divider(thickness: 2),
              Padding(
                padding: _fieldPadding,
                child: FormBuilderRadioGroup<bool>(
                  name: 'use-ref',
                  separator: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('or'),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  options: const [
                    FormBuilderFieldOption(
                      value: true,
                      child: Text('Reference'),
                    ),
                    FormBuilderFieldOption(
                      value: false,
                      child: Text('Purpose'),
                    ),
                  ],
                  initialValue: useRef,
                  onChanged: (value) {
                    setState(() {
                      useRef = value!;
                    });
                  },
                ),
              ),
              // if (useRef)
              _ReferenceInputField(enabled: useRef),
              // else
              _PurposeInputField(enabled: !useRef),
              const Divider(thickness: 2.0),
              const _NoteInputField(),
              Padding(
                padding: _fieldPadding,
                child: Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code, size: 18),
                    label: const Text('SHOW CODE'),
                    onPressed: () => _showCode(context),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showCode(BuildContext context) {
    if (!_formKey.currentState!.saveAndValidate()) return;

    var values = _formKey.currentState!.value;
    var newData = EpcQrData.fromMap(values);

    GetIt.I.get<SharedPreferences>()
      ..setString('name', newData.name)
      ..setString('iban', newData.iban)
      ..setString('bic', newData.bic);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewCodePage(qrData: newData),
      ),
    );
  }
}

class _NameInputField extends StatelessWidget {
  const _NameInputField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _fieldPadding,
      child: FormBuilderTextField(
        name: 'name',
        initialValue: GetIt.I.get<SharedPreferences>().getString('name'),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.person),
          label: Text('Name'),
          border: OutlineInputBorder(),
        ),
        validator: FormBuilderValidators.required(),
        inputFormatters: [LengthLimitingTextInputFormatter(70)],
        autofillHints: const [
          AutofillHints.creditCardName,
          AutofillHints.name,
        ],
      ),
    );
  }
}

class _IbanInputField extends StatelessWidget {
  const _IbanInputField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _fieldPadding,
      child: FormBuilderTextField(
        name: 'iban',
        initialValue: GetIt.I.get<SharedPreferences>().getString('iban'),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.numbers),
          label: Text('IBAN'),
          border: OutlineInputBorder(),
        ),
        inputFormatters: [LengthLimitingTextInputFormatter(34)],
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
          // FormBuilderValidators.creditCard(),
        ]),
        autofillHints: const [AutofillHints.creditCardNumber],
      ),
    );
  }
}

class _BicInputField extends StatelessWidget {
  const _BicInputField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _fieldPadding,
      child: FormBuilderTextField(
        name: 'bic',
        initialValue: GetIt.I.get<SharedPreferences>().getString('bic'),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.account_balance),
          label: Text('BIC'),
          border: OutlineInputBorder(),
        ),
        inputFormatters: [LengthLimitingTextInputFormatter(11)],
      ),
    );
  }
}

class _AmountInputField extends StatelessWidget {
  const _AmountInputField({Key? key}) : super(key: key);

  static final amountRegExp = RegExp(r'^\d{0,9}([\.,]\d{0,2})?$');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _fieldPadding,
      child: FormBuilderTextField(
        name: 'amount',
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.euro),
          label: Text('Amount'),
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(12),
          FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
          TextInputFormatter.withFunction((oldValue, newValue) {
            return amountRegExp.matchAsPrefix(newValue.text) != null
                ? newValue
                : oldValue;
          }),
        ],
        valueTransformer: (value) =>
            num.tryParse(value?.replaceAll(',', '.') ?? ''),
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.min(0.01),
          FormBuilderValidators.max(999999999.99),
        ]),
      ),
    );
  }
}

class _ReferenceInputField extends StatelessWidget {
  const _ReferenceInputField({
    required this.enabled,
    Key? key,
  }) : super(key: key);

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _fieldPadding,
      child: FormBuilderTextField(
        key: _refKey,
        name: 'reference',
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.code),
          label: Text('Payment reference'),
          border: OutlineInputBorder(),
        ),
        validator: FormBuilderValidators.maxLength(140),
        enabled: enabled,
      ),
    );
  }
}

class _PurposeInputField extends StatelessWidget {
  const _PurposeInputField({
    required this.enabled,
    Key? key,
  }) : super(key: key);

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _fieldPadding,
      child: FormBuilderTextField(
        key: _refTextKey,
        name: 'referenceText',
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.comment),
          label: Text('Purpose'),
          border: OutlineInputBorder(),
        ),
        validator: FormBuilderValidators.maxLength(140),
        enabled: enabled,
      ),
    );
  }
}

class _NoteInputField extends StatelessWidget {
  const _NoteInputField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _fieldPadding,
      child: FormBuilderTextField(
        name: 'note',
        decoration: InputDecoration(
          prefixIcon: Transform.scale(
            scaleX: -1.0,
            child: const Icon(Icons.comment),
          ),
          label: const Text('Note for the payer'),
          // hintText: 'A message for the payer',
          border: const OutlineInputBorder(),
        ),
        validator: FormBuilderValidators.maxLength(70),
      ),
    );
  }
}
