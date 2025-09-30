import 'package:flutter/material.dart';

/// Customer search bar widget
class CustomerSearchBar extends StatefulWidget {
  final Function(String) onSearchChanged;

  const CustomerSearchBar({super.key, required this.onSearchChanged});

  @override
  State<CustomerSearchBar> createState() => _CustomerSearchBarState();
}

class _CustomerSearchBarState extends State<CustomerSearchBar> {
  final TextEditingController _controller = TextEditingController();
  // Removed unused field

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Müşteri ara...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    widget.onSearchChanged('');
                    setState(() {
                      // Note: _isSearching field was removed
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          widget.onSearchChanged(value);
          setState(() {
            // Note: _isSearching field was removed
          });
        },
        onSubmitted: (value) {
          widget.onSearchChanged(value);
        },
      ),
    );
  }
}
