class ProductFilter {
  String? category;
  String? tag;
  double? minPrice;
  double? maxPrice;
  String? searchQuery;

  ProductFilter({
    this.category,
    this.tag,
    this.minPrice,
    this.maxPrice,
    this.searchQuery,
  });
}