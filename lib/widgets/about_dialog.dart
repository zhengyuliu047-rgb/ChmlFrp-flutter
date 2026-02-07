import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class ChmlAboutDialog extends StatelessWidget {
  const ChmlAboutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题
            Text(
              '关于 ChmlFrp',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                fontFamily: "HarmonyOS Sans",
              ),
            ),
            const SizedBox(height: 24),

            // 作者信息和头像
            Column(
              children: [
                // 圆形头像
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/b_eabec14b96e98a610b58afbc411a55b7.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '作者：初',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                    fontFamily: "HarmonyOS Sans",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 应用信息
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoItem(label: '版本', value: '1.4.1'),
                InfoItem(label: '平台', value: 'Flutter 跨平台'),
                InfoItem(label: '描述', value: 'ChmlFrp 客户端'),
              ],
            ),
            const SizedBox(height: 24),

            // Gitee 仓库链接
            GestureDetector(
              onTap: () async {
                final url = Uri.parse('https://gitee.com/initial-qwq/flutter_chmlfrp');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                  border: Border.all(color: AppTheme.primaryColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.code, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Gitee 仓库',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                        fontFamily: "HarmonyOS Sans",
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 关闭按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                  ),
                ),
                child: const Text('关闭', style: TextStyle(fontFamily: "HarmonyOS Sans")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const InfoItem({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$label：',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontFamily: "HarmonyOS Sans",
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontFamily: "HarmonyOS Sans",
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}