# stage1: generate LC_MESSAGES
FROM jumpserver/core-ce:v3.10.3 as stage1
RUN sed -i 's/\(msgstr\s\+.\+\)JumpServer/\1vPlatfrom/i' /opt/jumpserver/apps/locale/zh/LC_MESSAGES/django.po && \
    sed -i 's/开源堡垒机/操作平面/' /opt/jumpserver/apps/locale/zh/LC_MESSAGES/django.po && \
    sed -i 's/\(msgstr\s\+.\+\)JumpServer/\1vPlatfrom/i' /opt/jumpserver/apps/locale/ja/LC_MESSAGES/django.po && \
    sed -i 's/开源堡垒机/操作平面/' /opt/jumpserver/apps/locale/ja/LC_MESSAGES/django.po

WORKDIR /opt/jumpserver
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    apt update && apt install -y gettext && \
    django-admin compilemessages

# final
FROM jumpserver/core-ce:v3.10.3
COPY ./modified/* /opt/jumpserver/apps/static/img/
RUN sed -i 's/FIT2CLOUD 飞致云/vPlatform/' /opt/jumpserver/apps/jumpserver/context_processor.py && \
    sed -i 's/{{ COPYRIGHT }}/vPlatform/' /opt/jumpserver/apps/templates/_copyright.html
COPY --from=stage1 /opt/jumpserver/apps/locale/* /opt/jumpserver/apps/locale/
