# JIBON RUNNER — Godot 4.4.1

বাংলাদেশের গ্রাম, রাস্তা ও মাঠের আবহে তৈরি 3D endless-runner গেমের চলমান প্রোটোটাইপ।

## চালানো
Godot 4.4.1 দিয়ে `GodotProject` ফোল্ডার খুলে `Scenes/Main.tscn` চালান।

## নিয়ন্ত্রণ
- মোবাইল: বামে/ডানে swipe করে lane বদল; ওপরের দিকে swipe = jump; নিচে swipe = slide।
- কম্পিউটার: Left/Right বা A/D = lane; Up/W/Space = jump; Down/S = slide; P = pause।
- Pause menu থেকে খেলা চালিয়ে যাওয়া বা নতুন করে শুরু করা যায়।
- Game Over হলে menu-এর Restart বোতাম ব্যবহার করুন।

## বর্তমানে থাকা ফিচার
- 3D তিন-lane endless runner, camera follow, procedural road।
- সবুজ ধানক্ষেতের আবহ, গাছ ও সাধারণ গ্রামের বাড়ি।
- swipe controls, jump/slide, coin pickup, obstacle collision।
- Score, distance, current coins, best score ও lifetime coin counter।
- Pause/resume/restart menu।
- Best score ও মোট কয়েন user://jibon_runner_save.cfg-এ সংরক্ষণ।

## এখনো বাকি
বাস্তবসম্মত character model/animation, বাংলাদেশি যানবাহন ও বিভিন্ন অঞ্চল, sound/music, ৫/১০/১৫/২০ কিমিতে আলাদা breakfast/food/rest gameplay, main menu, cosmetic shop, missions, daily rewards, day/night/weather cycle, আরও obstacle/coin pattern, accessibility/settings, performance profiling এবং বাস্তব Android device testing।

## Android build
GitHub Actions-এর JIBON RUNNER Android APK workflow APK export ও verify করে। সফল run-এর Artifacts অংশ থেকে APK ZIP ডাউনলোড করা যাবে।
