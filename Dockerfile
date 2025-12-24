# 阶段1：使用Hugo官方镜像构建静态文件
FROM klakegg/hugo:0.123.8-alpine AS builder
# 设置工作目录
WORKDIR /app
# 复制Hugo项目所有文件（需确保.gitignore未排除关键文件如content、themes）
COPY . .
# 构建静态文件（--minify 压缩资源，生产环境必选）
# 若使用主题子模块，需先执行 git submodule update --init
RUN hugo --minify

# 阶段2：使用轻量级Nginx托管静态文件
FROM nginx:1.25-alpine
# 复制构建好的静态文件到Nginx默认根目录
COPY --from=builder /app/public /usr/share/nginx/html
# 可选：自定义Nginx配置（如开启gzip、设置缓存）
COPY nginx.conf /etc/nginx/conf.d/default.conf
# 暴露80端口（Northflank需映射此端口）
EXPOSE 80
# 启动Nginx前台运行（容器必须保持前台进程）
CMD ["nginx", "-g", "daemon off;"]
