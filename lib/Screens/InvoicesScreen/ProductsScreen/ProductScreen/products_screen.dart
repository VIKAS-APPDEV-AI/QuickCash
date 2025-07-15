import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickcash/Screens/InvoicesScreen/ProductsScreen/AddProductScreen/add_product_screen.dart';
import 'package:quickcash/Screens/InvoicesScreen/ProductsScreen/ProductScreen/deleteProductModel/deleteProductApi.dart';
import 'package:quickcash/Screens/InvoicesScreen/ProductsScreen/ProductScreen/model/productApi.dart';
import 'package:quickcash/Screens/InvoicesScreen/ProductsScreen/ProductScreen/model/productModel.dart';
import 'package:quickcash/Screens/InvoicesScreen/ProductsScreen/ProductScreen/productDetailsModel/productDetailsApi.dart';
import 'package:quickcash/constants.dart';

import '../../../../util/customSnackBar.dart';
import '../UpdateProductScreen/update_product_Screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductApi _productApi = ProductApi();
  final DeleteProductApi _deleteProductApi = DeleteProductApi();
  List<ProductData> productList =[];

  bool isLoading =false;
  String? errorMessage;

  @override
  void initState() {
    mProduct();
    super.initState();
  }

  Future<void> mProduct() async{
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try{
      final response = await _productApi.productApi();

      if(response.productsList !=null && response.productsList!.isNotEmpty){
        setState(() {
          isLoading = false;
          errorMessage = null;

          productList = response.productsList!;

        });
      }else {
        setState(() {
          isLoading = false;
          errorMessage = 'No Product List';
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
    return DateFormat('dd-MM-yyyy').format(date);
  }

  // Delete Product Api ---------------
  Future<void> mDeleteProduct(String? productId) async {
    try{
      final response = await _deleteProductApi.deleteProductApi(productId!);

      if(response.message == "Product Data has been deleted successfully"){
        setState(() {
          mProduct();
          Navigator.of(context).pop();
          CustomSnackBar.showSnackBar(context: context, message: "Product Data has been deleted successfully!", color: kGreenColor);
        });
      }else{
        setState(() {
          Navigator.of(context).pop();
          CustomSnackBar.showSnackBar(context: context, message: "We are facing some issue!", color: kRedColor);
        });
      }

    }catch (error) {
      setState(() {
        Navigator.of(context).pop();
        CustomSnackBar.showSnackBar(context: context, message: "We are facing some issue!", color: kRedColor);
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
          "Products",
          style: TextStyle(color: Colors.transparent),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(defaultPadding),
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
                      onSaved: (value) {

                      },

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
                          child: Icon(Icons.search,color: kHintColor,),
                        ),
                      ),
                    ),
                  ),*/

                  const SizedBox(width: defaultPadding,),

                  FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddProductScreen()),
                      );
                    },
                    child: const Icon(Icons.add, color: kPrimaryColor,),
                  ),
                ],
              ),

              const SizedBox(height: largePadding,),

              isLoading ? const Center(
                child: CircularProgressIndicator(
                  color: kPrimaryColor,
                ),
              ) :ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: productList.length,
                itemBuilder: (context, index) {
                  final products = productList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: defaultPadding),
                    // Add spacing
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
                              const Text('Created Date:', style: TextStyle(
                                  color: Colors.white, fontSize: 16),),
                              Text(formatDate(products.date),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),),
                            ],
                          ),

                          const SizedBox(height: smallPadding,),
                          const Divider(color: kPrimaryLightColor,),
                          const SizedBox(height: smallPadding,),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Product Name:', style: TextStyle(
                                  color: Colors.white, fontSize: 16),),
                              Text('${products.productName}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),),
                            ],
                          ),

                          const SizedBox(height: smallPadding,),
                          const Divider(color: kPrimaryLightColor,),
                          const SizedBox(height: smallPadding,),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Category:', style: TextStyle(
                                  color: Colors.white, fontSize: 16),),
                              Text('${products.categoryDetails?.isNotEmpty == true ? products.categoryDetails!.first.name : ''}',style: const TextStyle(
                                  color: Colors.white, fontSize: 16),),

                            ],
                          ),

                          const SizedBox(height: smallPadding,),
                          const Divider(color: kPrimaryLightColor,),
                          const SizedBox(height: smallPadding,),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Price:', style: TextStyle(
                                  color: Colors.white, fontSize: 16),),
                              Text('${products.unitPrice}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),),
                            ],
                          ),

                          const SizedBox(height: smallPadding,),
                          const Divider(color: kPrimaryLightColor,),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Expanded(child: Text("Action:",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16))),

                              IconButton(
                                icon: const Icon(
                                  Icons.remove_red_eye, color: Colors.white,),
                                onPressed: () {

                                  String? categoryName = products.categoryDetails?.isNotEmpty == true ? products.categoryDetails!.first.name : '';

                                  mViewProduct(context,products.id!,categoryName!);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit, color: Colors.white,),
                                onPressed: () {
                                  String? categoryName = products.categoryDetails?.isNotEmpty == true ? products.categoryDetails!.first.name : '';

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => EditProductScreen(productId: products.id!, category: categoryName)),
                                  );

                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete, color: Colors.white,),
                                onPressed: () {
                                  _showDeleteClientDialog(products.id);
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

  Future<bool> _showDeleteClientDialog(String? productId) async {
    return (await showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text("Delete Product"),
            content: const Text("Do you really want to delete this product?"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // No
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () {
                 mDeleteProduct(productId);
                },
                child: const Text("Yes"),
              ),
            ],
          ),
    )) ?? false;
  }


  void mViewProduct(BuildContext context, String id, String category) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ViewProduct(productId: id, mCategory: category);
      },
    );
  }
}

class ViewProduct extends StatefulWidget {
  final String productId;
  final String mCategory;
  const ViewProduct({super.key, required this.productId, required this.mCategory});

  @override
  State<ViewProduct>  createState() => _ViewProductState();
}

class _ViewProductState extends State<ViewProduct> {
  final ProductDetailsApi _productDetailsApi = ProductDetailsApi();

  final TextEditingController name = TextEditingController();
  final TextEditingController productCode = TextEditingController();
  final TextEditingController category = TextEditingController();
  final TextEditingController unitPrice = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController lastUpdate = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    mProductDetail();
    super.initState();
  }

  Future<void> mProductDetail() async{
    try{
      final response = await _productDetailsApi.productDetailsApi(widget.productId);

      name.text = response.productName ?? 'N/A';
      productCode.text = response.productCode ?? 'N/A';
      category.text = widget.mCategory;
      unitPrice.text = (response.unitPrice ?? 0.0).toString();
      description.text = response.description ?? 'N/A';
      lastUpdate.text = formatDate(response.date);

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

  // Function to format the date
  String formatDate(String? dateTime) {
    if (dateTime == null) {
      return 'Date not available';
    }
    DateTime date = DateTime.parse(dateTime);
    return DateFormat('dd-MM-yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      child: isLoading ? const Center(
        child: CircularProgressIndicator(
          color: kPrimaryColor,
        ),
      ) : SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'View Product',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: kPrimaryColor),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: name,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              cursorColor: kPrimaryColor,
              onSaved: (value){},
              readOnly: true,
              style: const TextStyle(color: kPrimaryColor),

              decoration: InputDecoration(
                labelText: "Name",
                labelStyle: const TextStyle(color: kPrimaryColor),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide()
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),

            const SizedBox(height: defaultPadding),
            TextFormField(
              controller: productCode,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              cursorColor: kPrimaryColor,
              onSaved: (value) {},
              readOnly: true,
              style: const TextStyle(color: kPrimaryColor),

              decoration: InputDecoration(
                labelText: "Product Code",
                labelStyle: const TextStyle(color: kPrimaryColor),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide()
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),

            const SizedBox(height: defaultPadding),
            TextFormField(
              controller: category,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              cursorColor: kPrimaryColor,
              onSaved: (value) {},
              readOnly: true,
              style: const TextStyle(color: kPrimaryColor),

              decoration: InputDecoration(
                labelText: "Category",
                labelStyle: const TextStyle(color: kPrimaryColor),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide()
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),

            const SizedBox(height: defaultPadding),
            TextFormField(
              controller: unitPrice,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              cursorColor: kPrimaryColor,
              onSaved: (value) {},
              readOnly: true,
              style: const TextStyle(color: kPrimaryColor),

              decoration: InputDecoration(
                labelText: "Unit Price",
                labelStyle: const TextStyle(color: kPrimaryColor),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide()
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),

            const SizedBox(height: defaultPadding),
            TextFormField(
              controller: description,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              cursorColor: kPrimaryColor,
              onSaved: (value) {},
              readOnly: true,
              maxLines: 4,
              minLines: 1,
              style: const TextStyle(color: kPrimaryColor),
              decoration: InputDecoration(
                labelText: "Description",
                labelStyle: const TextStyle(color: kPrimaryColor),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide()
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),

            const SizedBox(height: defaultPadding),
            TextFormField(
              controller: lastUpdate,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              cursorColor: kPrimaryColor,
              onSaved: (value) {},
              readOnly: true,
              style: const TextStyle(color: kPrimaryColor),

              decoration: InputDecoration(
                labelText: "Last Update",
                labelStyle: const TextStyle(color: kPrimaryColor),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide()
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),


            const SizedBox(height: 30.0),
          ],
        ),
      ),
    );
  }
}



