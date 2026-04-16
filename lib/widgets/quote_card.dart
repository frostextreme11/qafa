import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glass_card.dart';

class QuoteCard extends StatelessWidget {
  final String quote;

  const QuoteCard({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      isAsymmetric: true,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Icon(
              Icons.format_quote_rounded,
              size: 40,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Text(
                quote,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white.withOpacity(0.9) 
                    : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}