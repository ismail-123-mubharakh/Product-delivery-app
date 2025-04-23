 import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:untitled/home/model_class/product_filter.dart';
import 'package:untitled/home/model_class/product_model_class.dart';
import 'package:untitled/home/service_class/product_service_class.dart';

class ProductViewModel extends ChangeNotifier{
  ProductDetailsModel? productDetailsModel;
  List<Product>? productsList;
  List<Product> filteredProducts = [];
  List<Product> searchProductList = [];
  bool isFilterApplied = false;
  bool isSearchApplied = false;
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  File? _profileImage;

  Future<void> getProductDetails(BuildContext context) async {
    try {
      isLoading = true;
      final value = await ProductService.fetchProducts();

      if (value != null && value.products != null) {
        productDetailsModel = value;
        productsList ??= []; // initialize if null
        productsList!.addAll(productDetailsModel!.products!);
        print("product------- $productsList");
      } else {
        print("No products found or API returned null.");
      }
    } catch (e) {
      print("Error fetching products: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  List<Product> allProducts = [];
  ProductFilter currentFilter = ProductFilter();

  void updateFilter(ProductFilter newFilter) {
    currentFilter = newFilter;
    notifyListeners();
  }

  void loadProducts(List<Product> products) {
    allProducts = products;
    notifyListeners();
  }
  void applyFilters(ProductFilter filter) {
    isFilterApplied = true;
    currentFilter = filter;
    filteredProducts = productsList!.where((product) {
      // Check category match (if category filter is set)
      final categoryMatch = currentFilter.category == null ||
          product.category == currentFilter.category;

      // Check tag match (if tag filter is set)
      final tagMatch = currentFilter.tag == null ||
          product.tags!.contains(currentFilter.tag);

      // Check price range (if price filters are set)
      final priceMatch = (currentFilter.minPrice == null ||
          product.price! >= currentFilter.minPrice!) &&
          (currentFilter.maxPrice == null ||
              product.price! <= currentFilter.maxPrice!);

      // Return true if all active filters match
      return categoryMatch && tagMatch && priceMatch;
    }).toList();
    notifyListeners();
  }

// Add this getter to access the filtered list
  List<Product> get filteredProductsList => filteredProducts;

  void resetFilters() {
    isFilterApplied = false;
    filteredProducts.clear();
    currentFilter = ProductFilter(); // Clear all filter conditions
    filteredProducts.addAll(productsList!); // Reset to show all products
    notifyListeners();
  }
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    print(_searchQuery.toString());
    _applySearch();
    notifyListeners();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      searchProductList = List.from(productsList ?? []);
      return;
    }

    searchProductList = productsList?.where((product) {
      return product.title?.toLowerCase().contains(_searchQuery) ?? false;
    }).toList() ?? [];

  }

  void clearSearch() {
    _searchQuery = '';
    _applySearch();
    notifyListeners();
  }
  File? get profileImage => _profileImage;

   setProfileImage(File image) {
    _profileImage = image;
    notifyListeners();
  }
}