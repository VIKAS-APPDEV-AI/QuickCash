import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickcash/Screens/InvoicesScreen/CategoriesScreen/addCategoriesModel/addCategoriesApi.dart';
import 'package:quickcash/Screens/InvoicesScreen/CategoriesScreen/addCategoriesModel/addCategoriesModel.dart';
import 'package:quickcash/Screens/InvoicesScreen/CategoriesScreen/categoriesModel/categoriesApi.dart';
import 'package:quickcash/Screens/InvoicesScreen/CategoriesScreen/categoriesModel/categoriesModel.dart';
import 'package:quickcash/Screens/InvoicesScreen/CategoriesScreen/deleteCategoriesModel/deleteCategoryApi.dart';
import 'package:quickcash/Screens/InvoicesScreen/CategoriesScreen/updateCategoriesModel/updateCategoriesApi.dart';
import 'package:quickcash/Screens/InvoicesScreen/CategoriesScreen/updateCategoriesModel/updateCategoriesModel.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/auth_manager.dart';
import 'package:quickcash/util/customSnackBar.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final DeleteCategoryApi _deleteCategoryApi = DeleteCategoryApi();
  final AddCategoriesApi _addCategoriesApi = AddCategoriesApi();
  final UpdateCategoriesApi _updateCategoriesApi = UpdateCategoriesApi();
  final CategoriesApi _categoriesApi = CategoriesApi();
  List<CategoriesData> categories = [];


  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    mCategories();
    super.initState();
  }

  Future<void> mCategories() async{
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _categoriesApi.categoriesApi();

      if(response.categoriesList !=null && response.categoriesList!.isNotEmpty){
        setState(() {
          categories = response.categoriesList!;
          isLoading = false;
        });
      }else {
        setState(() {
          isLoading = false;
          errorMessage = 'No Categories';
        });
      }

    }catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  // Function to format the date
  String formatDate(String? dateTime) {
    if (dateTime == null) {
      return 'Date not available';
    }
    DateTime date = DateTime.parse(dateTime);
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Update Category Api -----------------
  Future<void> mUpdateCategory(String categoryName, String? categoryID) async{
    try{
      final request = UpdateCategoriesRequest(categoryName: categoryName);
      final response = await _updateCategoriesApi.updateCategory(request, categoryID);

      if(response.message == "User Category details has been updated successfully"){
        setState(() {
          mCategories();
          Navigator.of(context).pop();
          CustomSnackBar.showSnackBar(context: context, message: "Category updated successfully!", color: kGreenColor);
        });
      }else{
        setState(() {
          Navigator.of(context).pop();
          CustomSnackBar.showSnackBar(context: context, message: "We are facing some issue!", color: kRedColor);
        });
      }

    }catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  Future<void> mAddCategory(String categoryName) async{
    try{
      final request = AddCategoriesRequest(userId: AuthManager.getUserId(), categoryName: categoryName);
      final response = await _addCategoriesApi.addCategories(request);
      if(response.message == "Category has been added Successfully!!!"){
        setState(() {
          mCategories();
          Navigator.of(context).pop();
          CustomSnackBar.showSnackBar(context: context, message: "Category has been added Successfully!", color: kGreenColor);
        });
      }else{
        setState(() {
          Navigator.of(context).pop();
          CustomSnackBar.showSnackBar(context: context, message: "We are facing some issue!", color: kRedColor);
        });
      }
    }catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  Future<void> mDeleteCategory(String? categoryId) async {
    try{
      final response = await _deleteCategoryApi.deleteCategoryApi(categoryId!);

      if(response.message == "Category Data has been deleted successfully"){
        setState(() {
          mCategories();
          Navigator.of(context).pop();
          CustomSnackBar.showSnackBar(context: context, message: "Category Data has been deleted successfully!", color: kGreenColor);
        });
      }else{
        setState(() {
          Navigator.of(context).pop();
          CustomSnackBar.showSnackBar(context: context, message: "We are facing some issue!", color: kRedColor);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.transparent),
        title: const Text(
          "Categories",
          style: TextStyle(color: Colors.transparent),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /*Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      cursorColor: kPrimaryColor,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(defaultPadding),
                          borderSide: const BorderSide(),
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        hintText: "Search",
                        hintStyle: const TextStyle(color: kHintColor),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(defaultPadding),
                          child: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),*/
                  const SizedBox(width: defaultPadding),
                  FloatingActionButton(
                    onPressed: () {
                      // Add your onPressed code here
                      _addCategoryDialog();
                    },
                    child: const Icon(Icons.add, color: kPrimaryColor),
                  ),
                ],
              ),
              const SizedBox(height: largePadding),
              isLoading ? const Center(
                child: CircularProgressIndicator(
                  color: kPrimaryColor,
                ),
              ) :ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: defaultPadding),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(defaultPadding),
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Created Date:', style: TextStyle(color: Colors.white, fontSize: 16)),
                              Text(formatDate(category.date), style: const TextStyle(color: Colors.white, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: smallPadding),
                          const Divider(color: kPrimaryLightColor),
                          const SizedBox(height: smallPadding),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Category:', style: TextStyle(color: Colors.white, fontSize: 16)),
                              Text('${category.categoriesName}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: smallPadding),
                          const Divider(color: kPrimaryLightColor),
                          const SizedBox(height: smallPadding),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Product:', style: TextStyle(color: Colors.white, fontSize: 16)),
                              Text('${category.productDetails!.length}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: smallPadding),
                          const Divider(color: kPrimaryLightColor),
                          const SizedBox(height: smallPadding),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Expanded(child: Text("Action:", style: TextStyle(color: Colors.white, fontSize: 16))),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.white),
                                onPressed: () {
                                  _editCategoryDialog(category.categoriesName, category.id);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.white),
                                onPressed: () {
                                  _showDeleteClientDialog(category.id);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editCategoryDialog(String? categoriesName, String? id) async {
    final TextEditingController categoryController = TextEditingController(text: categoriesName);

    // Form key for validation
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Category'),
          content: Form( // Wrap in Form to enable validation
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: categoryController, // Set controller to TextFormField
                  keyboardType: TextInputType.text,
                  cursorColor: kPrimaryColor,
                  textInputAction: TextInputAction.none,
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: const TextStyle(color: kPrimaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Category is required';
                    }
                    return null; // Validation passed
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) { // Validate the form

                  setState(() {
                    categoriesName = categoryController.text;
                    mUpdateCategory(categoryController.text, id);
                  });

                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _addCategoryDialog() async {
    final TextEditingController categoryName = TextEditingController();

    // Form key for validation
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Category'),
          content: Form( // Wrap in Form to enable validation
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: categoryName,
                  keyboardType: TextInputType.text,
                  cursorColor: kPrimaryColor,
                  textInputAction: TextInputAction.none,
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: const TextStyle(color: kPrimaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Category is required';
                    }
                    return null; // Validation passed
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) { // Validate the form
                  setState(() {
                    mAddCategory(categoryName.text);
                  });
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }


  Future<bool> _showDeleteClientDialog(String? id) async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Category"),
        content: const Text("Do you really want to delete this category?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // No
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              mDeleteCategory(id);
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    )) ?? false;
  }
}
