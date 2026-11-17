# JIBON RUNNER — জীবন রানার

বাংলাদেশের গ্রাম, বাজার, শহর ও রাস্তার অনুপ্রেরণায় 3D endless runner গেম।

## নতুন মূল ইঞ্জিন: Godot
এখন থেকে নতুন গেম ডেভেলপমেন্ট হবে `GodotProject/` ফোল্ডারে Godot 4 দিয়ে। Unity Personal License আর এই নতুন প্রজেক্টের জন্য প্রয়োজন নেই। পুরোনো Unity প্রোটোটাইপের ফাইলগুলো আপাতত রেফারেন্স হিসেবে রাখা হয়েছে; Godot প্রজেক্ট যাচাই না হওয়া পর্যন্ত সেগুলো মুছে ফেলা হবে না।

## Godot প্রোটোটাইপ
- তিন লেনের দৌড়, টাচ swipe ও keyboard control
- লাফ, স্লাইড, কয়েন সংগ্রহ ও বাধায় ধাক্কা লাগলে Game Over
- procedural road segments, সবুজ মাঠ, গাছ ও সাধারণ গ্রামের বাড়ি
- স্কোর ও দূরত্বের HUD

## ফোনে পরীক্ষা
GitHub Actions থেকে `JIBON RUNNER Web Demo` workflow চালিয়ে Web export artifact তৈরি করার ব্যবস্থা যোগ করা হয়েছে। এটি Android Chrome-এ প্রাথমিক gameplay পরীক্ষা করতে সাহায্য করবে। Web demo চূড়ান্ত Android APK নয়।

## Android APK
Godot Android export-এর জন্য export templates, Android SDK/JDK ও signing configuration সঠিকভাবে সেট করতে হবে। এগুলো আলাদা build workflow-এ যুক্ত করে APK তৈরি ও বাস্তব ফোনে পরীক্ষা করা হবে। APK তৈরি হয়েছে—এমন দাবি করা হচ্ছে না।

## পরবর্তী কাজ
বাস্তবসম্মত বাংলাদেশি 3D assets, চরিত্রের animation, বাস/ট্রাক/রিকশা/ট্রেন, দিন-রাত/আবহাওয়া, খাবারের বিরতি (৫/১০/১৫/২০ কিমি), বাংলা UI, sound design, save system, Android export ও device QA।
