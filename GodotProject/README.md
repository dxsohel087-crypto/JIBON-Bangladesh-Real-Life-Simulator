# JIBON RUNNER — Godot 4.4.1

বাংলাদেশের গ্রাম, ধানক্ষেত, বাজার ও রাস্তার আবহে তৈরি 3D endless-runner গেম।

## চালানো ও নিয়ন্ত্রণ
Godot 4.4.1 দিয়ে `GodotProject` ফোল্ডার খুলে `Scenes/Main.tscn` চালান।
- মোবাইল: বামে/ডানে swipe = lane বদল; ওপরের দিকে swipe = jump; নিচের দিকে swipe = slide।
- কম্পিউটার: Left/Right বা A/D = lane; Up/W/Space = jump; Down/S = slide; P = pause।
- Pause menu থেকে খেলা চালিয়ে যাওয়া, নতুন করে শুরু, পোশাকের দোকান, মিশন ও দৈনিক পুরস্কার ব্যবহার করা যায়।

## বর্তমান প্রোটোটাইপে
- 3D তিন-lane endless runner, camera follow, procedural road ও coin collection।
- বাংলাদেশের ধানক্ষেত, সেচের নালা, গাছ, গ্রামের বাড়ি, রাস্তার বাজারের স্টল ও পুকুরের দৃশ্য।
- বিভিন্ন road barrier, কাঠের বাক্স, হাতগাড়ি, রিকশা ও মিনিবাসের বাধা।
- Jump/slide, swipe controls, score, distance, pause, restart ও Game Over।
- দৌড়ানোর সময় হাত-পায়ের swing animation।
- দিন-রাতের আলো পরিবর্তন এবং pause menu থেকে বৃষ্টি চালু/বন্ধের ব্যবস্থা।
- ৫/১০/১৫/২০ কিমিতে বিরতি; বিরতির সময় 3D রাস্তার খাবারের দোকান/বসার জায়গা দেখা যায়।
- ১ কিমি ও ২০ কয়েনের মিশন অগ্রগতি।
- দৈনিক ৫০ কয়েন পুরস্কার (ডিভাইসের স্থানীয় তারিখ অনুযায়ী একবার)।
- ১০০ কয়েনে চরিত্রের পোশাকের রং পরিবর্তন।
- Best score, কয়েন, পোশাক ও দৈনিক পুরস্কারের তথ্য স্থানীয় save file-এ রাখা হয়।

## এখনো উন্নয়নের কাজ
এটি এখনো প্রাথমিক playable prototype, সম্পূর্ণ বাণিজ্যিক মানের গেম নয়। উন্নত human 3D character model/rig, বাস্তব animation, animated rickshaw/bus/train traffic, বড় শহর ও flyover levels, rain/fog weather, sound/music, উন্নত menu/settings, আরও missions/skins, accessibility, performance profiling এবং বিভিন্ন Android ফোনে বাস্তব device testing বাকি।

## Android build
GitHub Actions-এর `JIBON RUNNER Android APK` workflow APK export ও verify করে। সফল run-এর Artifacts অংশ থেকে APK ZIP ডাউনলোড করা যাবে।
