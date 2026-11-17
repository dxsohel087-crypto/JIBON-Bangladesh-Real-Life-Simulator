# JIBON RUNNER — Godot 4 project

বাংলাদেশের গ্রাম, রাস্তা ও মাঠের আবহে তৈরি 3D endless-runner গেমের প্রাথমিক সংস্করণ।

## চালানো
Godot 4.4.1 দিয়ে `GodotProject` ফোল্ডার খুলে `Scenes/Main.tscn` চালান।

## নিয়ন্ত্রণ
- মোবাইল: বামে/ডানে swipe করে lane বদল; ওপরের দিকে swipe করলে jump; নিচে swipe করলে slide।
- কম্পিউটার: Left/Right বা A/D = lane; Up/W/Space = jump; Down/S = slide।
- Game Over হলে স্ক্রিনে টাচ বা Enter/Space চাপলে নতুন করে শুরু হবে।

## এই সংস্করণে
- তিনটি lane, সামনের দিকে চলা runner, camera follow।
- procedural রাস্তা, সবুজ মাঠ, গাছ ও সাধারণ গ্রামের বাড়ি।
- swipe direction সংশোধন, jump/slide state, coin pickup ও obstacle collision-এর নিজস্ব distance check।
- score, coin ও distance HUD; Game Over/restart।

## এখনো সম্পূর্ণ হয়নি
এটি পরীক্ষামূলক playable foundation, পূর্ণাঙ্গ গেম নয়। বাস্তবসম্মত character model/animation, বাংলাদেশি যানবাহন ও লোকেশন, sound/music, breakfast/food/rest break scenes, main menu, shop, missions, daily rewards, save system, weather/day-night cycle এবং বাস্তব Android device testing এখনো বাকি। ৫/১০/১৫/২০ কিমি HUD-এ milestone দেখায়, কিন্তু এখনো আলাদা food-break gameplay নেই।

## Android build
GitHub Actions-এর `JIBON RUNNER Android APK` workflow APK export করে এবং artifact হিসেবে আপলোড করে। সফল workflow run-এর Artifacts অংশ থেকে APK নামানো যাবে।
