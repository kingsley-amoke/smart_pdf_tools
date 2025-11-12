// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:smart_pdf_tools/presentation/viewmodels/document_provider.dart';

// class QuickActionRow extends StatelessWidget {
//   const QuickActionRow({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<DocumentProvider>(context, listen: false);

//     final actions = [
//       {
//         'icon': Icons.camera_alt_rounded,
//         'label': 'Scan',
//         'onTap': () async => await provider.scanDocument(),
//       },
//       {
//         'icon': Icons.photo_library_rounded,
//         'label': 'Import',
//         'onTap': () async => await provider.importAndCreatePdf(),
//       },
//       {
//         'icon': Icons.merge_type_rounded,
//         'label': 'Merge',
//         'onTap': () async => await provider.mergePdfs(),
//       },
//       {
//         'icon': Icons.compress_rounded,
//         'label': 'Compress',
//         'onTap': () async => await provider.compressPdf(),
//       },
//     ];

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: actions
//           .map(
//             (a) => _QuickActionTile(
//               icon: a['icon'] as IconData,
//               label: a['label'] as String,
//               onTap: a['onTap'] as VoidCallback,
//             ),
//           )
//           .toList(),
//     );
//   }
// }

// class _QuickActionTile extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;
//   const _QuickActionTile({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Expanded(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 2),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(18),
//           onTap: onTap,
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(18),
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 220),
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 16,
//                   horizontal: 4,
//                 ),
//                 decoration: BoxDecoration(
//                   color: isDark
//                       ? Colors.white.withOpacity(0.05)
//                       : Colors.white.withOpacity(0.8),
//                   borderRadius: BorderRadius.circular(18),
//                   border: Border.all(
//                     color: isDark
//                         ? Colors.white.withOpacity(0.08)
//                         : Colors.black.withOpacity(0.06),
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.03),
//                       blurRadius: 8,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       icon,
//                       size: 26,
//                       color: Theme.of(context).colorScheme.primary,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       label,
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w500,
//                         color: isDark
//                             ? Colors.white.withOpacity(0.9)
//                             : Colors.black87,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pdf_tools/presentation/viewmodels/document_provider.dart';

class QuickActionRow extends StatelessWidget {
  const QuickActionRow({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DocumentProvider>(context, listen: false);

    final actions = [
      {
        'icon': Icons.camera_alt_rounded,
        'label': 'Scan',
        'onTap': provider.scanDocument,
      },
      {
        'icon': Icons.photo_library_rounded,
        'label': 'Import',
        'onTap': provider.importAndCreatePdf,
      },
      {
        'icon': Icons.merge_type_rounded,
        'label': 'Merge',
        'onTap': provider.mergePdfs,
      },
      {
        'icon': Icons.compress_rounded,
        'label': 'Compress',
        'onTap': provider.compressPdf,
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions
          .map(
            (a) => _QuickActionTile(
              icon: a['icon'] as IconData,
              label: a['label'] as String,
              onTap: a['onTap'] as VoidCallback,
            ),
          )
          .toList(),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.06),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 26,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.white.withOpacity(0.9)
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
