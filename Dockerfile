# 基础镜像：官方Nginx Alpine版（多架构，支持amd64/arm64/armv8）
FROM nginx:alpine

# 镜像元信息
LABEL maintainer="Solara Docker Build"
LABEL name="Solara"
LABEL description="现代化网页音乐播放器 Solara (光域) - 多架构Docker镜像"
LABEL architecture="amd64/arm64/armv8"

# 第一步：清理Nginx默认静态资源
RUN rm -rf /usr/share/nginx/html/*

# 第二步：复制Solara项目所有文件到Nginx静态目录
COPY . /usr/share/nginx/html

# 第三步：覆盖Nginx默认配置（内置SPA路由，无需额外nginx.conf）
RUN echo 'server { \
    listen 80; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html; \
    charset utf-8; \
    # 支持前端路由（解决单页应用刷新404） \
    location / { \
        try_files $uri $uri/ /index.html; \
        add_header X-Frame-Options "SAMEORIGIN"; \
        add_header X-XSS-Protection "1; mode=block"; \
        add_header X-Content-Type-Options "nosniff"; \
    } \
    # 静态资源缓存（提升加载速度） \
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ { \
        expires 7d; \
        add_header Cache-Control "public, max-age=604800"; \
        add_header Access-Control-Allow-Origin *; \
    } \
    # 禁止访问敏感文件（安全加固） \
    location ~ /\.git|/\.env|/\.dockerignore { \
        deny all; \
        return 403; \
    } \
    # 日志配置 \
    access_log /var/log/nginx/solara-access.log; \
    error_log /var/log/nginx/solara-error.log; \
}' > /etc/nginx/conf.d/default.conf

# 暴露80端口（兼容Docker端口映射）
EXPOSE 80

# 启动Nginx（前台运行，保证容器不退出）
CMD ["nginx", "-g", "daemon off;"]