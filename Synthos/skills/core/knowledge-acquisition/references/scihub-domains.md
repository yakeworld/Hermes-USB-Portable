# Sci-Hub 域名与CDN

CDN直连(首选): https://sci.bban.top/pdf/{doi}.pdf — ~0.7s，无验证码
域名池: sci-hub.ru / sci-hub.st / sci-hub.ee / sci-hub.se / sci-net.xyz

论文<=2024: CDN+Sci-Hub均可用
论文>=2025: CDN不可用，Sci-Hub部分可用

故障处理: 503/403->换代理; DNS封->换域名; altcha验证码->关掉走CDN直连
