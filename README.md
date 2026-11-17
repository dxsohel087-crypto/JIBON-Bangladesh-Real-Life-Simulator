# JIBON RUNNER — জীবন রানার

বাংলাদেশের গ্রাম, বাজার ও রাস্তার অনুপ্রেরণায় Android 3D endless runner.

## এই ধাপে যোগ হয়েছে
- তিন লেনের দৌড়, swipe/keyboard control, jump এবং slide.
- দূরত্ব ও ৫/১০/১৫/২০ কিমি food-break event.
- খাবারের বিরতিতে পুরো গেমের simulation pause.
- কয়েন, বাধা, score এবং best-distance save.
- Unity Editor থেকে starter scene তৈরি এবং Android build method.
- Runtime prototype: endless road segments, green fields, village houses/trees, player placeholder, obstacles, coins এবং HUD.

## Unity version
Unity 2022.3.62f1

## Starter scene
1. Unity 2022.3.62f1 দিয়ে project খুলুন।
2. Package import শেষ হলে Menu থেকে JIBON RUNNER > Create Starter Scene নির্বাচন করুন।
3. Assets/Scenes/JibonRunner.unity খুলে Play চাপুন।

## GitHub Actions দিয়ে APK
Repository Settings > Secrets and variables > Actions-এ UNITY_LICENSE নামে Unity Personal/Pro license file-এর secret যোগ করতে হবে। তারপর Actions tab থেকে JIBON RUNNER Android APK workflow manually চালু করুন। সফল হলে workflow artifact-এ APK থাকবে। License secret ছাড়া build চালানো যাবে না।

## সত্যিকারের বর্তমান অবস্থা
এটি প্রথম playable-prototype foundation, final game নয়। Runtime environment এখন primitive placeholder; photorealistic character/vehicle/building models, real animation, Bengali font asset, licensed ambience/audio, full menus, performance optimization এবং Android device test এখনো বাকি। APK তৈরি বা পরীক্ষা হয়েছে—এমন দাবি করা হচ্ছে না।
