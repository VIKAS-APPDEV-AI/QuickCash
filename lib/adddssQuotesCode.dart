import 'package:flutter/material.dart';
import 'package:quickcash/Screens/InvoicesScreen/ProductsScreen/ProductScreen/model/productApi.dart';
import 'package:quickcash/Screens/InvoicesScreen/ProductsScreen/ProductScreen/model/productModel.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/model/taxApi/taxApi.dart';
import 'package:quickcash/model/taxApi/taxApiModel.dart';
import 'package:quickcash/util/customSnackBar.dart';

class AddsssCodeScreen extends StatefulWidget {
  const AddsssCodeScreen({super.key});

  @override
  State<AddsssCodeScreen> createState() => _AddQuoteScreenState();
}

class _AddQuoteScreenState extends State<AddsssCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductApi _productApi = ProductApi();
  final TaxApi _taxApi = TaxApi();

  List<ProductData> productLists =[];
  List<TaxData> taxList =[];
  List<String> selectedTaxes = [];
  List<String> selectedTaxesCalculate = [];


  final TextEditingController discount = TextEditingController();
  String selectedDiscount = 'Select Discount';
  String selectedTax = 'Select Tax';
  ProductData? selectedProduct;
  String subTotal = "0.00";
  String showDiscount = "0.00";
  String showTaxes = "0.00";
  String showTotalAmount = "0.00";
  double totalTaxValue = 0;

  bool isLoading = false;
  String? errorMessage;

  List<Map<String, dynamic>> productList = [
    {"selectedProduct": null, "quantity": "", "price": ""}
  ];

  @override
  void initState() {
    mProduct();
    mTaxes();
    super.initState();
  }

  Future<void> mProduct() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _productApi.productApi();
      if (response.productsList != null && response.productsList!.isNotEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = null;
          productLists = response.productsList!;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No Product List';
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }


  Future<void> mTaxes() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try{
      final response = await _taxApi.taxesApi();

      if(response.taxesList !=null && response.taxesList!.isNotEmpty){
        isLoading = false;
        errorMessage = null;
        taxList = response.taxesList!;
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No Tax List';
        });
      }
    }catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  void addProduct() {
    if (productList.length < productLists.length) {
      setState(() {
        productList.add({"selectedProduct": null, "quantity": "", "price": ""});
      });
      // Print the updated productList or the newly added product
      print("Product added: ${productList.last}");
      print("Updated productList: $productList");
    } else {
      // Show a message or alert that no more products can be added
      CustomSnackBar.showSnackBar(
        context: context,
        message: 'You cannot add more products.',
        color: kPrimaryColor,
      );
    }
  }


  void removeProduct(int index) {
    if (productList.length > 1) {
      setState(() {
        productList.removeAt(index);
        _calculateTotalTaxValue();
        mCalculateTax();
        mDiscount();
        mTotalAmount();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Add Quote",
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
              children: <Widget>[
                const SizedBox(height: largePadding),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: productList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: smallPadding),
                            child: Container(
                              padding: const EdgeInsets.all(defaultPadding),
                              decoration: BoxDecoration(
                                color: Colors.white,
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
                                  const SizedBox(height: largePadding),
                                  // Product Dropdown
                                  DropdownButtonFormField<ProductData?>(
                                    value: productList[index]['selectedProduct'],
                                    style: const TextStyle(color: kPrimaryColor),
                                    decoration: InputDecoration(
                                      labelText: 'Product',
                                      labelStyle: const TextStyle(color: kPrimaryColor),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(),
                                      ),
                                    ),
                                    items: productLists.map((ProductData product) {
                                      return DropdownMenuItem<ProductData?>(
                                        value: product,
                                        child: Text(
                                          product.productName!,
                                          style: const TextStyle(color: kPrimaryColor, fontSize: 16),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        productList[index]['selectedProduct'] = newValue;
                                        // Set the price when a product is selected
                                        if (newValue != null) {
                                          setState(() {
                                            productList[index]['price'] = newValue.unitPrice.toString();
                                            productList[index]['quantity'] = "1";
                                            calculateAmount(index);
                                            mDiscount();
                                            mCalculateTax();
                                            mTotalAmount();
                                          });
                                        } else {
                                          setState(() {
                                            productList[index]['price'] = "";
                                            productList[index]['quantity'] = "0";
                                            calculateAmount(index);
                                            mDiscount();
                                            mCalculateTax();
                                            mTotalAmount();
                                          });
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(height: largePadding),
                                  // Quantity Field
                                  TextFormField(
                                    controller: TextEditingController(
                                      text: productList[index]['quantity'], // Default to '1' if null or empty
                                    ),
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: kPrimaryColor),
                                    decoration: InputDecoration(
                                      labelText: "Quantity",
                                      labelStyle: const TextStyle(color: kPrimaryColor),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        productList[index]['quantity'] = value;
                                        // Recalculate the amount when the quantity is changed
                                        calculateAmount(index);
                                        mDiscount();
                                        mCalculateTax();
                                        mTotalAmount();
                                      });
                                    },
                                  ),
                                  const SizedBox(height: largePadding),
                                  // Price Field
                                  TextFormField(
                                    controller: TextEditingController(
                                      text: productList[index]['price'], // Display the price here
                                    ),
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: kPrimaryColor),
                                    decoration: InputDecoration(
                                      labelText: "Price",
                                      labelStyle: const TextStyle(color: kPrimaryColor),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    readOnly: true,
                                    onChanged: (value) {
                                      setState(() {
                                        productList[index]['price'] = value; // User can manually update the price
                                        // Recalculate the amount when the price is changed
                                        calculateAmount(index);
                                        mDiscount();
                                        mCalculateTax();
                                        mTotalAmount();
                                      });
                                    },
                                  ),
                                  const SizedBox(height: largePadding),
                                  // Amount Calculation (Quantity * Price)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Amount", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 14),
                                        child: Text(
                                          productList[index]['amount'] ?? "0.00", // Display the amount here
                                          style: const TextStyle(
                                              color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: smallPadding),
                                  // Delete Button
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Action", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            removeProduct(index);
                                          });
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
                      // Add Product Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FloatingActionButton(
                            onPressed: () {
                              addProduct();
                            },
                            child: const Icon(Icons.add, color: kPrimaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: defaultPadding,),
                      const SizedBox(height: largePadding,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          SizedBox(
                            width: 100, // Set your desired fixed width here
                            child: TextFormField(
                              controller: discount,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              cursorColor: kPrimaryColor,
                              style: const TextStyle(color: kPrimaryColor),
                              onChanged: (value) {
                                setState(() {
                                  mDiscount();
                                  mCalculateTax();
                                  mTotalAmount();
                                });
                              },
                              enabled: selectedDiscount != "Select Discount",
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(defaultPadding),
                                  borderSide: const BorderSide(),
                                ),
                                hintText: "0",
                                hintStyle: const TextStyle(color: kPrimaryColor),
                              ),
                            ),
                          ),


                          const SizedBox(width: defaultPadding,),
                          Expanded(child: DropdownButtonFormField<String>(
                            value: selectedDiscount,
                            style: const TextStyle(color: kPrimaryColor),

                            decoration: InputDecoration(
                              labelText: 'Discount',
                              labelStyle: const TextStyle(color: kPrimaryColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(),
                              ),
                            ),

                            items: ['Select Discount', 'Fixed', 'Percentage']
                                .map((String role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(role, style: const TextStyle(
                                    color: kPrimaryColor, fontSize: 16),),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectedDiscount = newValue!;
                                discount.clear();
                                showDiscount = "0.00";
                              });
                            },
                          ),
                          ),
                        ],
                      ),

                      const SizedBox(height: largePadding,),
                      GestureDetector(
                        onTap: _showMultiSelectDialog,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Select Taxes',
                            labelStyle: const TextStyle(color: kPrimaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(),
                            ),
                            suffixIcon: const Icon(Icons.arrow_drop_down, color: kPrimaryColor),
                          ),
                          child: Text(
                            selectedTaxes.isEmpty
                                ? 'Select Taxes'
                                : selectedTaxes.join(', '),
                            style: const TextStyle(color: kPrimaryColor),
                          ),
                        ),
                      ),

                      const SizedBox(height: 35,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Sub Total:",
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                            child: Text(
                              subTotal, // Dynamically updated value
                              style: const TextStyle(
                                color: kPrimaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),


                      const SizedBox(height: defaultPadding,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Discount:", style: TextStyle(color: kPrimaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),),
                          Padding(padding: const EdgeInsets.symmetric(
                              horizontal: defaultPadding),
                            child: Text(
                              showDiscount,
                              style: const TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),),),
                        ],
                      ),

                      const SizedBox(height: defaultPadding,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Tax:", style: TextStyle(color: kPrimaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),),
                          Padding(padding: const EdgeInsets.symmetric(
                              horizontal: defaultPadding),
                            child: Text(showTaxes, style: const TextStyle(
                                color: kPrimaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),),),
                        ],
                      ),

                      const SizedBox(height: defaultPadding,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total:", style: TextStyle(color: kPrimaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),),
                          Padding(padding: const EdgeInsets.symmetric(
                              horizontal: defaultPadding),
                            child: Text(showTotalAmount, style: const TextStyle(
                                color: kPrimaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),),),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void mDiscount() {
    double discountAmount = 0;

    if (selectedDiscount == "Fixed") {
      setState(() {
        discountAmount = double.tryParse(discount.text) ?? 0;
        showDiscount = discountAmount.toStringAsFixed(2);
      });
    } else if (selectedDiscount == "Percentage") {
      setState(() {
        double totalPrice = double.tryParse(subTotal.toString()) ?? 0;
        double percentage = double.tryParse(discount.text) ?? 0;

        if (percentage > 0 && totalPrice > 0) {
          discountAmount = (percentage / 100) * totalPrice;
          showDiscount = discountAmount.toStringAsFixed(2);
        } else {
          showDiscount = "0.00";
        }
      });
    }
  }

  void mCalculateTax() {
    double taxAmount = 0;

    setState(() {
      double totalPrice = double.tryParse(subTotal.toString()) ?? 0;
      double? percentage = double.tryParse(totalTaxValue.toStringAsFixed(2)) ?? 0;

      if(percentage >0 && totalPrice> 0){
        taxAmount = (percentage / 100) * totalPrice;
        showTaxes = taxAmount.toStringAsFixed(2);
      }else{
        showTaxes = "0.00";
      }
    });
  }

  void mTotalAmount() {
    double totalAmount = 0;

    setState(() {
      double totalPrice = double.tryParse(subTotal.toString()) ?? 0.0;
      double? percentage = double.tryParse(showDiscount.toString()) ?? 0.0;
      double? taxes = double.tryParse(showTaxes.toString()) ?? 0.0;

      if(totalPrice > 0 && percentage >0  && taxes > 0){
        totalAmount = totalPrice - percentage + taxes;
        showTotalAmount = totalAmount.toStringAsFixed(2);
      }else if(totalPrice >0 && percentage >0){
        totalAmount = totalPrice - percentage;
        showTotalAmount = totalAmount.toStringAsFixed(2);
      }else if(totalPrice >0 && taxes >0){
        totalAmount = totalPrice + taxes;
        showTotalAmount = totalAmount.toStringAsFixed(2);
      }else if(totalPrice >0){
        totalAmount = totalPrice;
        showTotalAmount = totalPrice.toStringAsFixed(2);
      } else{
        showTotalAmount = "0.00";
      }
    });
  }


  void calculateSubTotalAmount() {
    double totalAmount = 0;

    for (var product in productList) {
      final amount = double.tryParse(product['amount'] ?? '0') ?? 0;
      totalAmount += amount;
    }

    setState(() {
      subTotal = totalAmount.toStringAsFixed(2);
      mDiscount();
      mCalculateTax();
      mTotalAmount();
    });
  }

  void calculateAmount(int index) {
    final quantity = double.tryParse(productList[index]['quantity'] ?? '0') ?? 0;
    final price = double.tryParse(productList[index]['price'] ?? '0') ?? 0;

    if (quantity != 0) {
      final amount = quantity * price;
      setState(() {
        productList[index]['amount'] = amount.toStringAsFixed(2);
      });
    } else {
      setState(() {
        final amount = price;
        productList[index]['price'] = amount.toStringAsFixed(2);
      });
    }

    // Recalculate the total amount every time an individual amount changes
    calculateSubTotalAmount();
    mDiscount();
    mCalculateTax();
    mTotalAmount();
  }


  // Method to display the multi-select dropdown using a custom widget
  void _showMultiSelectDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Taxes'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  children: taxList.map((tax) {
                    return CheckboxListTile(
                      title: Text(
                        '${tax.name ?? ''} - ${tax.taxValue ?? ''}',
                        style: const TextStyle(color: kPrimaryColor),
                      ),
                      value: selectedTaxes.contains('${tax.name ?? ''} - ${tax.taxValue ?? ''}'),
                      onChanged: (bool? isSelected) {
                        setState(() {
                          if (isSelected == true) {
                            selectedTaxes.add('${tax.name ?? ''} - ${tax.taxValue ?? ''}');
                          } else {
                            selectedTaxes.remove('${tax.name ?? ''} - ${tax.taxValue ?? ''}');
                          }
                          // Recalculate the total tax value
                          totalTaxValue = _calculateTotalTaxValue();
                          mCalculateTax();
                          mTotalAmount();
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }



  double _calculateTotalTaxValue() {
    double total = 0.0;
    for (var selectedTax in selectedTaxes) {
      final tax = taxList.firstWhere(
            (tax) => '${tax.name ?? ''} - ${tax.taxValue ?? ''}' == selectedTax,
        orElse: () => TaxData(name: '', taxValue: 0),
      );
      total += (tax.taxValue ?? 0).toDouble();
    }
    return total;
  }

}




