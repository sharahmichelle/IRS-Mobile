import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:upm_drrm_irs_mobile/models/news_model.dart';

class NewsDetailScreen extends StatelessWidget {
  final News news;

  const NewsDetailScreen({super.key, required this.news});

  // ── Theme colours (aligned with TermsPrivacyScreen) ───────────────────────
  static const Color _primaryRed    = Color(0xFFE63946);
  static const Color _darkRed       = Color(0xFF9D0208);
  static const Color _white         = Color(0xFFF8F9FA);
  static const Color _surfaceWhite  = Color(0xFFFFFFFF);
  static const Color _textPrimary   = Color(0xFF212529);
  static const Color _textSecondary = Color(0xFF6C757D);
  static const Color _borderColor   = Color(0xFFE9ECEF);

  static const LinearGradient _headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE63946), Color(0xFF9D0208)],
  );

  // ── Category helpers ───────────────────────────────────────────────────────
  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'update':       return const Color(0xFF2A9D8F);
      case 'event':        return const Color(0xFF4CC9F0);
      case 'tech':         return const Color(0xFF457B9D);
      case 'alert':        return _primaryRed;
      case 'announcement': return const Color(0xFFE9C46A);
      default:             return _textSecondary;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'update':       return Icons.system_update_rounded;
      case 'event':        return Icons.event_rounded;
      case 'tech':         return Icons.computer_rounded;
      case 'alert':        return Icons.warning_rounded;
      case 'announcement': return Icons.campaign_rounded;
      default:             return Icons.info_rounded;
    }
  }

  // ── URL launcher ───────────────────────────────────────────────────────────
  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open the link.'),
            backgroundColor: _primaryRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  // ── Formatted date ─────────────────────────────────────────────────────────
  String _formattedDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h    = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m    = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  ·  $h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColor(news.category);
    final categoryIcon  = _categoryIcon(news.category);
    final hasImage      = news.imageUrl  != null && news.imageUrl!.isNotEmpty;
    final hasSource     = news.sourceUrl != null && news.sourceUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: _white,
      body: Column(
        children: [
          // ── Header (mirrors TermsPrivacyScreen._buildHeader) ───────────────
          _buildHeader(context),

          // ── Scrollable body ─────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero image ──────────────────────────────────────────────
                  if (hasImage)
                    GestureDetector(
                      onTap: hasSource
                          ? () => _launchUrl(context, news.sourceUrl!)
                          : null,
                      child: SizedBox(
                        width: double.infinity,
                        height: 220,
                        child: Image.network(
                          news.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: _borderColor,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: _primaryRed,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            color: _borderColor,
                            child: const Center(
                              child: Icon(Icons.broken_image_rounded,
                                  color: _textSecondary, size: 48),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // ── Content ─────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Category badge (retained) ────────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(categoryIcon,
                                  color: categoryColor, size: 13),
                              const SizedBox(width: 6),
                              Text(
                                news.category.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: categoryColor,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ── Title ────────────────────────────────────────────
                        Text(
                          news.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _textPrimary,
                            letterSpacing: -0.5,
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Author & date ────────────────────────────────────
                        Row(
                          children: [
                            const Icon(Icons.person_outline_rounded,
                                size: 14, color: _textSecondary),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '${news.author}  ·  ${_formattedDate(news.publishedAt)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        Divider(color: _borderColor, thickness: 1),
                        const SizedBox(height: 24),

                        // ── Section label (mirrors _buildSectionHeader) ───────
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 18,
                              decoration: BoxDecoration(
                                color: _primaryRed,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Full Article',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: _textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ── Article body ─────────────────────────────────────
                        Text(
                          news.content,
                          style: const TextStyle(
                            fontSize: 14,
                            color: _textSecondary,
                            height: 1.7,
                          ),
                        ),

                        // ── Source button ────────────────────────────────────
                        if (hasSource) ...[
                          const SizedBox(height: 28),
                          Divider(color: _borderColor, thickness: 1),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _launchUrl(context, news.sourceUrl!),
                              icon: const Icon(Icons.open_in_new_rounded,
                                  size: 16),
                              label: const Text('Read Original Article'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryRed,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header — identical structure to TermsPrivacyScreen._buildHeader ─────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        gradient: _headerGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 24),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'News Detail',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}