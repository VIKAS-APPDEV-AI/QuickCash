import 'dart:math';
import 'package:flutter/material.dart';
import 'package:quickcash/Screens/InvoicesScreen/ProductsScreen/UpdateProductScreen/model/updateProductApi.dart';
import 'package:quickcash/Screens/InvoicesScreen/ProductsScreen/UpdateProductScreen/model/updateProductModel.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/auth_manager.dart';

import '../../../../util/customSnackBar.dart';
import '../../CategoriesScreen/categoriesModel/categoriesApi.dart';
import '../../CategoriesScreen/categoriesModel/categoriesModel.dart';
import '../ProductScreen/productDetailsModel/productDetailsApi.dart';

class EditProductScreen extends StatefulWidget {
  final String? productId;
  final String? category;
  const EditProductScreen({super.key, required this.productId, required this.category});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final CategoriesApi _categoriesApi = CategoriesApi();
  final ProductDetailsApi _productDetailsApi = ProductDetailsApi();
  final UpdateProductApi _updateProductApi = UpdateProductApi();


  final TextEditingController name = TextEditingController();
  final TextEditingController unitPrice = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController productCode = TextEditingController();


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String selectedCategory = 'Select Category';

  bool isLoading = true;
  String? errorMessage;
  List<CategoriesData> categoriesList = [];
  String? selectedCategoryId;

  // Function to generate a random product code
  String generateRandomCode(int length) {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(length, (index) => characters[random.nextInt(characters.length)]).join();
  }

  void updateProductCode() {
    setState(() {
      String newCode = generateRandomCode(12); // Change 12 to any length you prefer
      productCode.text = newCode; // Update the text controller
    });
  }

  @override
  void initState() {
    super.initState();
    updateProductCode();
    mCategory();
    mProductDetail();
  }

  // Category Api ------------------------------
  Future<void> mCategory() async {
    setState(() {
      isLoading = false;
      errorMessage = null;
    });

    try {
      final response = await _categoriesApi.categoriesApi();

      if (response.categoriesList != null && response.categoriesList!.isNotEmpty) {
        setState(() {
          categoriesList = response.categoriesList!;
          isLoading = false;

        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No Categories';
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  //Product Details Api
  Future<void> mProductDetail() async{
    try{
      final response = await _productDetailsApi.productDetailsApi(widget.productId);

      name.text = response.productName ?? 'N/A';
      productCode.text = response.productCode ?? 'N/A';
      selectedCategory = widget.category ?? '';
      unitPrice.text = (response.unitPrice ?? 0.0).toString();
      description.text = response.description ?? 'N/A';

      final selectedCategoryData = categoriesList.firstWhere((category) => category.categoriesName == selectedCategory);
      selectedCategoryId = selectedCategoryData.id;

      setState(() {
        isLoading = false;
        errorMessage = null;
      });
    }catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  // Update Product Api -------
  Future<void> mUpdateProduct(String categoryId) async{
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    int mUnitPrice = int.parse(unitPrice.text);

    try{
      final request = UpdateProductRequest(userId: AuthManager.getUserId(), name: name.text, categoryId: categoryId, description: description.text, productCode: productCode.text, unitPrice: mUnitPrice);
      final response = await _updateProductApi.updateProduct(request, widget.productId);

      if(response.message == "User Product details has been updated successfully"){
        setState(() {
          isLoading = false;
          errorMessage = null;
          CustomSnackBar.showSnackBar(context: context, message: "Product details has been updated successfully!", color: kGreenColor);

        });
      }else{
        setState(() {
          isLoading = false;
          errorMessage = null;
          CustomSnackBar.showSnackBar(context: context, message: errorMessage!, color: kRedColor);
        });
      }

    }catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  @override
  void dispose() {
    productCode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Update Product",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: largePadding),
                TextFormField(
                  controller: name,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  cursorColor: kPrimaryColor,
                  style: const TextStyle(color: kPrimaryColor),
                  decoration: InputDecoration(
                    labelText: "Name",
                    labelStyle: const TextStyle(color: kPrimaryColor, fontSize: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: largePadding),
                TextFormField(
                  controller: productCode, // Use the controller
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  cursorColor: kPrimaryColor,
                  readOnly: true,
                  style: const TextStyle(color: kPrimaryColor),
                  decoration: InputDecoration(
                    labelText: "Product Code",
                    labelStyle: const TextStyle(color: kPrimaryColor, fontSize: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    suffixIcon: GestureDetector(
                      onTap: updateProductCode, // Call the function on tap
                      child: const Padding(
                        padding: EdgeInsets.all(defaultPadding),
                        child: Icon(Icons.repeat, color: kPrimaryColor,),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: largePadding),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  style: const TextStyle(color: kPrimaryColor),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: const TextStyle(color: kPrimaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  items: [
                    'Select Category',
                    ...categoriesList.map((category) => category.categoriesName!),
                  ].map((String categoryName) {
                    return DropdownMenuItem(
                      value: categoryName,
                      child: Text(categoryName, style: const TextStyle(color: kPrimaryColor, fontSize: 16)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedCategory = newValue!;
                      final selectedCategoryData = categoriesList.firstWhere((category) => category.categoriesName == selectedCategory);
                      selectedCategoryId = selectedCategoryData.id;
                    });
                  },
                  validator: (value) {
                    if (value == 'Select Category') {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: largePadding),
                TextFormField(
                  controller: unitPrice,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  cursorColor: kPrimaryColor,
                  style: const TextStyle(color: kPrimaryColor),
                  decoration: InputDecoration(
                    labelText: "Unit Price",
                    labelStyle: const TextStyle(color: kPrimaryColor, fontSize: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a unit price';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: largePadding),
                TextFormField(
                  controller: description,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  cursorColor: kPrimaryColor,
                  minLines: 6,
                  maxLines: 12,
                  style: const TextStyle(color: kPrimaryColor),
                  decoration: InputDecoration(
                    labelText: "Description",
                    labelStyle: const TextStyle(color: kPrimaryColor, fontSize: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: largePadding),
                if (isLoading) const Center(
                  child: CircularProgressIndicator(
                    color: kPrimaryColor,
                  ),
                ), // Show loading indicator
                if (errorMessage != null) // Show error message if there's an error
                  const Text('We are facing some issue?', style: TextStyle(color: Colors.red)),

                const SizedBox(height: 45),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        setState(() {
                          if (selectedCategoryId !=null) {
                            mUpdateProduct(selectedCategoryId!);
                          }else{
                            CustomSnackBar.showSnackBar(context: context, message: "message", color: kPrimaryColor);
                          }
                        });
                      }
                    },
                    child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
