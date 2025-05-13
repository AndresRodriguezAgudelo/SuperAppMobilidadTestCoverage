import 'package:flutter/material.dart';

class ListaDataHistorialVehicular extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const ListaDataHistorialVehicular({
    super.key,
    required this.data,
  });

  Widget _buildIcon(bool isCheck) {
    return Icon(
      isCheck ? Icons.check_circle : Icons.cancel,
      color: isCheck ? const Color(0xFF319E7C) : const Color(0xFFE05C3A),
      size: 24,
    );
  }

  Widget _buildValue(dynamic value) {
    if (value is bool) {
      return _buildIcon(value);
    }
    return Text(
      value.toString(),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color.fromARGB(221, 0, 0, 0),
      ),
      textAlign: TextAlign.end,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: Color(0xFF666666),
              ),
              SizedBox(height: 16),
              Text(
                'Estos datos no están disponibles por ahora',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: data.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        thickness: 0.5,
        color: Color.fromARGB(255, 154, 154, 154),
        indent: 16,
        endIndent: 16,
      ),
      itemBuilder: (context, index) {
        final item = data[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  item['label'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(137, 0, 0, 0),
                  ),
                ),
              ),
              Expanded(
                child: _buildValue(item['value']),
              ),
            ],
          ),
        );
      },
    );
  }
}
