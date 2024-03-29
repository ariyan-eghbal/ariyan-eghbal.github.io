---
layout: post
title: Zero Knowledge Proof
categories: [Math, Computer Science]
tags: [math, computer-science, zero-knowledge]
author: ryn
mermaid: true
lang: fa
math: true
---

اثبات بدون آگاهی یا همان Zero Knowledge Proof روشی است برای ثبات درستی یک گذاره به شخص دیگر بدون اینکه لازم باشد هیچ اطلاعاتی به جز همان اثبات را به او ارائه کرد. مثلا اگر من بتونم در اختیار داشتن یک الماس رو بدون نشان دادنش به شما ثابت کنم از ZKP استفاده کرده‌ام. دو نکته در این پازل وجود دارد، اول اینکه اثبات از طریق افشای اطلاعات خطرناکه و به راحتی میتونه اصل شی ارزشمند رو به خطر بندازه (مثلا یکی ممکنه الماس رو بدزده)، دوم اینکه زنجیره پذیر نیست یعنی اگر من داشته‌ام را از طریق افشای آن به شما اثبات کنم فقط به شما اثبات شده و شما نمیتوانید همینکار رو برای فرد سومی انجام دهید و به او ثابت کنید که من شی را در اختیار دارم. در مورد اشیا فیزیکی که نمیتونه در اختیار بیش از یک نفر باشه اثبات برای فرد سوم مستلزم انتقال مالکیت و در مورد اطلاعات که ذاتا در مالکیت انحصار پذیر نیستند و می‌توانند کپی شوند مستلزم افشای آنهاست (مثلا اگر من پسوردم رو به شما بگم شما هم برای اینکه ثابت کنید پسورد من رو دارید مجبورید اونو به نفر سوم بگید و به همین راحتی همه برای اینکه بفهمن من خودمم باید پسوردم رو بدونن).

به صورت کلی دو روش **تعاملی** و **غیرتعاملی** برای اینکار هست. روش تعاملی به صورت کلی بر پایه حل یک چالش و یا پازل که حل اون نیازمند در اختیار داشتن داده است، بنا میشه. و روش غیر تعاملی هم اساسا مبتنی بر ارائه تصویری از واقعیت است 🤔. عجیب شد؟ بیشتر توضیح میدم اما روش‌های غیر تعاملی که هم از نظر تئوری قابل اتکا باشن و هم در عمل قابل اجرا و نشت اطلاعات هم نداشته باشن وجود نداره پس عموما از همون روش تعاملی استفاده میشه.

بیاید یک مثال از روش تعاملی ببینیم تا قضیه واضح‌تر بشه.

مثلا فرض کنید من دو تا گوی دارم و ادعا میکنم رنگشون با هم فرق میکنه. برای اینکه ثابت کنم راست میگم ولی خود گوی ها رو نشون ندم میتونم اونا رو بزارم توی یک جعبه روی میز و چشمم رو ببندم و شما بسته به تصمیم خودتون جاشونو عوض کنید یا نه حالا من چشممام رو باز میکنم و توی جعبه رو بدون اینکه شما ببینید نگاه میکنم و از روی رنگشون میفهمم شما جابجا کردید یا نه. اینو به شما میگم و شما مطمئن‌تر میشی که راست میگفتم رنگ‌ها فرق میکنن. ولی خب ممکنه شانسی گفته باشم پس شما بازی رو دوباره تکرار میکنی و هر بار که جواب درست منو میشنوی احتمال شانسی گفتنم نصف میشه. میتونیم این بازی رو 20 بار تکرار کنیم و بعد از دور بیستم احتمال شانسی گفتن من میشه
$${1\over{2^{20}}}=0.00005\%$$
شما میتونی هر چقدر خواستی بازی رو تکرار کنی و احتمال شانسی گفتن من به صفر میل میکنه و به همین سادگی میتونم ثابت کنم رنگ دو تا گوی فرق میکنه بدون اینکه گوی‌ها رو نشون بدم!

نکته جالب اینجاست که اگر نفر سومی بازی ما رو ببینه نمیتونه مطمئن باشه که از قبل با هم هماهنگ نکردیم! پس در واقع به نفر سوم ناظر ثابت نمیشه رنگ‌ها واقعا فرق میکنن. در واقع این اثبات فقط بین من و شما کار میکنه و من کنترل خوبی دارم که به چه کسی اثبات میکنم و در مقابل نفر سومی میتونیم ادعا کنیم تبانی کردیم!

پازل کلاسیک مشابهی وجود داره که اولین بار در سال 1990 در مقاله‌ی "چطور اثبات بدون آگاهی را به کودکان خود آموزش دهید" با نام **غار علی‌بابا** منتشر شد[^1].

سال 1985  سه نفر به نام‌های Shafi Goldwasser، Silvio Micali و Charles Rackoff در مقاله‌ای[^2] روشی برای سنجش میزان دانش منتقل شده از فرد اثبات کننده به فرد تصدیق کننده ارائه و مفهوم پیچیدگی اطلاعاتی[^3] رو معرفی کردن و این حوزه جدید متولد شد.

نکته جالب اینه که ثابت میشه اگر یک مساله ریاضی اثبات داشته باشه حتما اثبات ZKP هم داره (پس اگر یکی از مسائل هزاره رو حل کنید میتونید بدون دادن راه حلش ثابت کنید حل کردید که اول پولو بگیرید 😉)


## کاربردها
این قصه جزو تحولات علوم کامپیوتر حساب میشه و کاربردهای تئوری و عملی مهمی داره. مثلا **احراز هویت** بدون اینکه لازم باشه پسورد رو در در جایی منتقل کنیم. **بلاکچین** رمز ارزها، اساس رمز ارزها بر شفافیت کامله و خب این قضیه میتونه حریم خصوصی رو به خطر بندازه، اینجا میشه بلاکچین و رمز ارزی داشت که با استفاده از ZKP کاملا ناشناس باشه در حالی که همزمان شفافیت لازم برای اعتماد در سیستم بلاکچین رو فراهم میکنه (مثلا ZeroCoin و Monero).

حتی ایده‌هایی مطرح شده تا از ZKP در حوزه خلع سلاح هسته‌ای برای اثبات هسته‌ای نبودن یک وسیله استفاده بشه بدون اینکه لازم باشه اطلاعات فنی اون وسیله افشا بشه.

ادامه دارد ...


[^1]: [doi:10.1007/0-387-34805-0_60](https://doi.org/10.1007%2F0-387-34805-0_60){:target="_blank"}
[^2]: [doi:10.1137/0218012](https://epubs.siam.org/doi/10.1137/0218012){:target="_blank"}
[^3]: Knowledge Complexity
