import 'package:epc_qr/qr_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormBuilderTextField(
                  name: 'name',
                  decoration: const InputDecoration(),
                  validator: FormBuilderValidators.required(),
                  inputFormatters: [LengthLimitingTextInputFormatter(70)],
                  autofillHints: const [
                    AutofillHints.creditCardName,
                    AutofillHints.name,
                  ],
                ),
                FormBuilderTextField(
                  name: 'iban',
                  decoration: const InputDecoration(),
                  inputFormatters: [LengthLimitingTextInputFormatter(34)],
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    // FormBuilderValidators.creditCard(),
                  ]),
                  autofillHints: const [AutofillHints.creditCardNumber],
                ),
                FormBuilderTextField(
                  name: 'bic',
                  decoration: const InputDecoration(),
                  inputFormatters: [LengthLimitingTextInputFormatter(11)],
                ),
                FormBuilderTextField(
                  name: 'amount',
                  decoration: const InputDecoration(),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(12),
                    FilteringTextInputFormatter.allow(r'[\d.,]'),
                    TextInputFormatter.withFunction(
                      (oldValue, newValue) {
                        if (RegExp(r'^\d*(?:[.,]\d{,2})?$')
                                .matchAsPrefix(newValue.text) !=
                            null) {
                          return newValue;
                        } else {
                          return oldValue;
                        }
                      },
                    )
                  ],
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.min(0.01),
                    FormBuilderValidators.max(999999999.99),
                  ]),
                ),
                FormBuilderRadioGroup<bool>(
                  name: 'use-ref',
                  options: const [
                    FormBuilderChipOption(
                      value: true,
                      child: Text('Reference'),
                    ),
                    FormBuilderChipOption(
                      value: false,
                      child: Text('Text'),
                    ),
                  ],
                  initialValue: useRef,
                  onChanged: (value) {
                    setState(() {
                      useRef = value!;
                    });
                  },
                ),
                FormBuilderTextField(
                  key: _refKey,
                  name: 'reference',
                  decoration: const InputDecoration(),
                  validator: FormBuilderValidators.maxLength(140),
                  enabled: useRef,
                ),
                FormBuilderTextField(
                  key: _refTextKey,
                  name: 'referenceText',
                  decoration: const InputDecoration(),
                  validator: FormBuilderValidators.maxLength(140),
                  enabled: !useRef,
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.qr_code, size: 18),
                  label: Text("GENERATE CODE"),
                  onPressed: () {
                    if (!_formKey.currentState!.saveAndValidate()) return;

                    var values = _formKey.currentState!.value;
                    var newData = EpcQrData.fromMap(values);
                    setState(() {
                      data = newData;
                    });
                  },
                )
              ],
            ),
          ),
          if (data != null)
            Container(
              constraints: BoxConstraints(maxHeight: 320, maxWidth: 320),
              child: QrImage(
                data: data!.toQrDataString(),
                errorCorrectionLevel: QrErrorCorrectLevel.M,
                // size: 200,
              ),
            ),
        ],
      ),
    );
  }
}
