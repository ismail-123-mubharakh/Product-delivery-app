
import 'package:flutter/material.dart';
import 'package:untitled/home/screens/product_detail_screen.dart';
import 'package:untitled/home/model_class/product_filter.dart';
import 'package:untitled/home/view_models/product_view_model.dart';
import 'package:provider/provider.dart';
import 'package:untitled/home/screens/profile_section.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
   context.read<ProductViewModel>().getProductDetails(context);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final productViewModel = Provider.of<ProductViewModel>(context);
    return WillPopScope(
      onWillPop: () async {
        // Show exit confirmation dialog
        final shouldExit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit App'),
            content: Text('Are you sure want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Cancel
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // OK
                child: Text('OK'),
              ),
            ],
          ),
        );

        // If OK is pressed, exit the app
        return shouldExit ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Home Page"),
          centerTitle: true,
          leading:IconButton(
            icon: Icon(Icons.account_box),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(),
                ),
              );
            },
          )
          ,
          actions: [
            IconButton(
              icon: Icon(Icons.filter_alt),
                onPressed: () async {
                  try {
                    // Get available categories (handle null category fields)
                    final availableCategories = productViewModel.productsList!
                        .map((p) => p.category ?? 'Uncategorized') // Handle null categories
                        .where((category) => category.isNotEmpty) // Filter out empty categories
                        .toSet()
                        .toList();

                    // Get available tags (handle null tags fields)
                    final availableTags = productViewModel.productsList!
                        .expand((p) => p.tags ?? <String>[]) // Handle null tags
                        .where((tag) => tag.isNotEmpty) // Filter out empty tags
                        .toSet()
                        .toList();

                    final newFilter = await showDialog<ProductFilter>(
                      context: context,
                      builder: (context) => ProductFilterDialog(
                        initialFilter: productViewModel.currentFilter,
                        availableCategories: availableCategories,
                        availableTags: availableTags,
                      ),
                    );

                    if (newFilter != null) {
                      productViewModel.updateFilter(newFilter);
                    }
                  } catch (e) {
                    debugPrint('Error in filter dialog: $e');
                    // Optionally show error to user
                  }
                },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller:  productViewModel.searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixIcon:  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      productViewModel.isSearchApplied = false;
                      Provider.of<ProductViewModel>(context, listen: false)
                          .clearSearch();
                      productViewModel.searchController.clear();
                    },
                  )
                ),
                onChanged: (value) {
                  Provider.of<ProductViewModel>(context, listen: false)
                      .setSearchQuery(value);
                  productViewModel.isSearchApplied = true;
                },
              ),
            ),
            Expanded(
              child: Consumer<ProductViewModel>(
                builder: (context, snapshot, _) {
                  // Add null check and empty state handling
                  if (snapshot.productsList == null) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.productsList!.isEmpty) {
                    return Center(child: Text("No products available"));
                  }
                  if(snapshot.isFilterApplied){
                  if (snapshot.filteredProducts.isEmpty) {
                    return Center(child: Text('No products available'));
                  }}
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemCount:snapshot.isSearchApplied ? snapshot.searchProductList .length :snapshot.isFilterApplied ? snapshot.filteredProductsList.length : snapshot.productsList!.length, // CRITICAL: Add this line
                    itemBuilder: (BuildContext context, int index) {
                      final product = snapshot.isSearchApplied ? snapshot.searchProductList[index] : snapshot.isFilterApplied ? snapshot.filteredProductsList[index] : snapshot.productsList![index];
                      return  GestureDetector(
                        onTap: () {
                          // Navigate to detail page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(product: product),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 3,
                          child: Column(
                            children: [
                              Expanded(
                                child: Image.network(
                                  product.thumbnail ?? '',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.error),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.title ?? 'No title',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 4),
                                    Text('\$${product.price?.toStringAsFixed(2) ?? 'N/A'}'),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.star, color: Colors.amber, size: 16),
                                        Text(product.rating?.toStringAsFixed(1) ?? 'N/A'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        ),
    );
  }
}

class ProductFilterDialog extends StatefulWidget {
  final ProductFilter initialFilter;
  final List<String> availableCategories;
  final List<String> availableTags;

  const ProductFilterDialog({
    Key? key,
    required this.initialFilter,
    required this.availableCategories,
    required this.availableTags,
  }) : super(key: key);

  @override
  _ProductFilterDialogState createState() => _ProductFilterDialogState();
}

class _ProductFilterDialogState extends State<ProductFilterDialog> {
  late ProductFilter _currentFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Filter Products'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _currentFilter.category,
              decoration: InputDecoration(labelText: 'Category'),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text('All Categories'),
                ),
                ...widget.availableCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _currentFilter.category = value;
                });
              },
            ),

            SizedBox(height: 16),

            // Tag Dropdown
            DropdownButtonFormField<String>(
              value: _currentFilter.tag,
              decoration: InputDecoration(labelText: 'Tag'),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text('All Tags'),
                ),
                ...widget.availableTags.map((tag) {
                  return DropdownMenuItem(
                    value: tag,
                    child: Text(tag),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _currentFilter.tag = value;
                });
              },
            ),

            SizedBox(height: 16),

            // Price Range
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Price Range'),
                RangeSlider(
                  values: RangeValues(
                    _currentFilter.minPrice ?? 0,
                    _currentFilter.maxPrice ?? 1000,
                  ),
                  min: 0,
                  max: 1000,
                  divisions: 20,
                  labels: RangeLabels(
                    '\$${(_currentFilter.minPrice ?? 0).toStringAsFixed(2)}',
                    '\$${(_currentFilter.maxPrice ?? 1000).toStringAsFixed(2)}',
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _currentFilter.minPrice = values.start;
                      _currentFilter.maxPrice = values.end;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('Reset'),
          onPressed: () {
            Navigator.of(context).pop(ProductFilter());
            final productProvider = Provider.of<ProductViewModel>(context, listen: false);
            productProvider.resetFilters();

          },
        ),
        TextButton(
          child: Text('Apply'),
          onPressed: () {
            Navigator.of(context).pop(_currentFilter);
            final productProvider = Provider.of<ProductViewModel>(context, listen: false);
            productProvider.applyFilters(_currentFilter);
          },
        ),
      ],
    );
  }
}
