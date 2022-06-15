import 'package:epc_qr/qr_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get_it/get_it.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _formKey = GlobalKey<FormBuilderState>();
final _refKey = GlobalKey();
final _refTextKey = GlobalKey();

class EpcQrFormPage extends StatefulWidget {
  const EpcQrFormPage({Key? key}) : super(key: key);

  @override
  State<EpcQrFormPage> createState() => _EpcQrFormPageState();
}

class _EpcQrFormPageState extends State<EpcQrFormPage> {
  EpcQrData? data;
  bool useRef = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          FormBuilder(
            key: _formKey,
            child: Expanded(
              child: ListView(
                children: [
                  const _NameInputField(),
                  const _IbanInputField(),
                  const _BicInputField(),
                  const _AmountInputField(),
                  const Divider(thickness: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                  ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code, size: 18),
                    label: const Text("GENERATE CODE"),
                    onPressed: () {
                      if (!_formKey.currentState!.saveAndValidate()) return;

                      var values = _formKey.currentState!.value;
                      var newData = EpcQrData.fromMap(values);
                      setState(() {
                        data = newData;
                      });

                      GetIt.I.get<SharedPreferences>()
                        ..setString('name', values['name'])
                        ..setString('iban', values['iban'])
                        ..setString('bic', values['bic']);
                    },
                  )
                ],
              ),
            ),
          ),
          if (data != null)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320, maxWidth: 320),
              child: QrImage(
                data: data!.toQrDataString(),
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
            ),
        ],
      ),
    );
  }
}

class _NameInputField extends StatelessWidget {
  const _NameInputField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FormBuilderTextField(
        name: 'name',
        initialValue: GetIt.I.get<SharedPreferences>().getString('name'),
        decoration: const InputDecoration(
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
      padding: const EdgeInsets.all(8.0),
      child: FormBuilderTextField(
        name: 'iban',
        initialValue: GetIt.I.get<SharedPreferences>().getString('iban'),
        decoration: const InputDecoration(
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
      padding: const EdgeInsets.all(8.0),
      child: FormBuilderTextField(
        name: 'bic',
        initialValue: GetIt.I.get<SharedPreferences>().getString('bic'),
        decoration: const InputDecoration(
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
      padding: const EdgeInsets.all(8.0),
      child: FormBuilderTextField(
        name: 'amount',
        decoration: const InputDecoration(
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
      padding: const EdgeInsets.all(8.0),
      child: FormBuilderTextField(
        key: _refKey,
        name: 'reference',
        decoration: const InputDecoration(
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
      padding: const EdgeInsets.all(8.0),
      child: FormBuilderTextField(
        key: _refTextKey,
        name: 'referenceText',
        decoration: const InputDecoration(
          label: Text('Purpose'),
          border: OutlineInputBorder(),
        ),
        validator: FormBuilderValidators.maxLength(140),
        enabled: enabled,
      ),
    );
  }
}
