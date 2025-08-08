import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickcash/Screens/UserProfileScreen/AdditionalInformationScreen/model/additionalInformationApi.dart';
import 'package:quickcash/util/apiConstants.dart';
import 'package:quickcash/util/error_handler.dart';
import 'package:quickcash/util/customSnackBar.dart';
import '../../../../constants.dart';

class AdditionalInfoScreen extends StatefulWidget {
  const AdditionalInfoScreen({super.key});

  @override
  State<AdditionalInfoScreen> createState() => _AdditionalInfoScreenState();
}

class _AdditionalInfoScreenState extends State<AdditionalInfoScreen> {
  final AdditionalInformationApi _additionalInformationApi = AdditionalInformationApi();

  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _documentSubmittedController = TextEditingController();
  final TextEditingController _documentNoController = TextEditingController();
  final TextEditingController _referralLinkController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    mAdditionalInformation();
  }

  void _copyReferralLink() {
    Clipboard.setData(ClipboardData(text: _referralLinkController.text)).then((_) {
      CustomSnackBar.showSnackBar(
        context: context,
        message: 'Referral link copied to clipboard!',
        color: Colors.green,
      );
    });
  }

  Future<void> mAdditionalInformation() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _additionalInformationApi.additionalInformation();

      _stateController.text = response.state ?? '';
      _cityController.text = response.city ?? '';
      _zipCodeController.text = response.postalCode ?? '';
      _documentSubmittedController.text =
          response.documentSubmitted != null ? mCapitalizeFirstLetter(response.documentSubmitted!) : '';
      _documentNoController.text = response.documentNo ?? '';

      if (response.referralDetails != null && response.referralDetails!.isNotEmpty) {
        final referralCode = response.referralDetails!.first.referralCode?.toString() ?? '';
        _referralLinkController.text = '${ApiConstants.baseReferralCodeUrl}$referralCode';
      } else {
        _referralLinkController.text = '';
      }

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });

      final message = getFriendlyErrorMessage(error);
      CustomSnackBar.showSnackBar(
        context: context,
        message: message,
        color: Colors.red,
      );
    }
  }

  String mCapitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  void dispose() {
    _stateController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _documentSubmittedController.dispose();
    _documentNoController.dispose();
    _referralLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              const SizedBox(height: defaultPadding),
              if (isLoading)
                 CircularProgressIndicator(color: Theme.of(context).extension<AppColors>()!.primary),

              const SizedBox(height: defaultPadding),

              _buildReadOnlyField("State", _stateController),
              _buildReadOnlyField("City", _cityController),
              _buildReadOnlyField("Zip Code", _zipCodeController),
              _buildReadOnlyField("Document Submitted", _documentSubmittedController),
              _buildReadOnlyField("Document Number", _documentNoController),

              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _referralLinkController,
                readOnly: true,
                maxLines: 4,
                minLines: 1,
                style: TextStyle(color: Theme.of(context).extension<AppColors>()!.primary),
                decoration: InputDecoration(
                  labelText: "Referral Link",
                  labelStyle: TextStyle(color: Theme.of(context).extension<AppColors>()!.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon:  Icon(Icons.copy, color: Theme.of(context).extension<AppColors>()!.primary),
                    onPressed: _copyReferralLink,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: defaultPadding),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        style: TextStyle(color: Theme.of(context).extension<AppColors>()!.primary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Theme.of(context).extension<AppColors>()!.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
