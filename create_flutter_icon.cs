using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;

class Program
{
    static void Main(string[] args)
    {
        // Create a Flutter-style icon
        using (Bitmap bitmap = new Bitmap(256, 256))
        {
            using (Graphics graphics = Graphics.FromImage(bitmap))
            {
                // Clear with transparent background
                graphics.Clear(Color.Transparent);
                
                // Set smoothing mode
                graphics.SmoothingMode = SmoothingMode.AntiAlias;
                
                // Create Flutter logo colors
                Color blue = Color.FromArgb(59, 130, 246);
                Color cyan = Color.FromArgb(6, 182, 212);
                Color green = Color.FromArgb(16, 185, 129);
                Color yellow = Color.FromArgb(245, 158, 11);
                
                // Draw Flutter logo shape
                // Main circle
                using (Brush brush = new LinearGradientBrush(new Point(0, 0), new Point(256, 256), blue, cyan))
                {
                    graphics.FillEllipse(brush, 32, 32, 192, 192);
                }
                
                // Flutter wings
                // Left wing
                using (Brush brush = new SolidBrush(green))
                {
                    graphics.FillEllipse(brush, 16, 64, 128, 128);
                }
                
                // Right wing
                using (Brush brush = new SolidBrush(yellow))
                {
                    graphics.FillEllipse(brush, 112, 64, 128, 128);
                }
                
                // Center circle
                using (Brush brush = new SolidBrush(Color.White))
                {
                    graphics.FillEllipse(brush, 96, 96, 64, 64);
                }
            }
            
            // Save as PNG
            bitmap.Save("flutter_icon.png", ImageFormat.Png);
            Console.WriteLine("Flutter icon created: flutter_icon.png");
            
            // Convert to ICO using built-in method
            // Note: This creates a basic ICO, for better results use a proper conversion tool
            using (FileStream fs = new FileStream("flutter_icon.ico", FileMode.Create))
            {
                bitmap.Save(fs, ImageFormat.Icon);
                Console.WriteLine("Flutter icon converted to ICO: flutter_icon.ico");
            }
        }
    }
}