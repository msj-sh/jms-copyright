ARG JMS_VERSION=v3.10.3

# stage1: generate LC_MESSAGES
FROM jumpserver/core-ce:$JMS_VERSION AS stage1

RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
RUN apt update && apt install -y gettext
RUN sed -i 's/\(msgstr\s\+.\+\)JumpServer/\1vPlatfrom/i' /opt/jumpserver/apps/locale/zh/LC_MESSAGES/django.po && \
    sed -i 's/开源堡垒机/操作平面/' /opt/jumpserver/apps/locale/zh/LC_MESSAGES/django.po && \
    sed -i 's/\(msgstr\s\+.\+\)JumpServer/\1vPlatfrom/i' /opt/jumpserver/apps/locale/ja/LC_MESSAGES/django.po && \
    sed -i 's/开源堡垒机/操作平面/' /opt/jumpserver/apps/locale/ja/LC_MESSAGES/django.po && \
    touch /opt/jumpserver/apps/locale/ja/LC_MESSAGES/modified && \
    touch /opt/jumpserver/apps/locale/zh/LC_MESSAGES/modified
WORKDIR /opt/jumpserver
RUN django-admin compilemessages

# final
FROM jumpserver/core-ce:$JMS_VERSION

WORKDIR /opt/jumpserver
COPY ./modified/* /opt/jumpserver/apps/static/img/
RUN sed -i 's/FIT2CLOUD 飞致云/vPlatfrom/' /opt/jumpserver/apps/jumpserver/context_processor.py && \
    sed -i 's/{{ COPYRIGHT }}/vPlatfrom/' /opt/jumpserver/apps/templates/_copyright.html
RUN rm -rf /opt/jumpserver/apps/locale/zh /opt/jumpserver/apps/locale/ja
COPY --from=stage1 /opt/jumpserver/apps/locale/LC_MESSAGES /opt/jumpserver/apps/locale/LC_MESSAGES
COPY --from=stage1 /opt/jumpserver/apps/locale/zh /opt/jumpserver/apps/locale/zh
COPY --from=stage1 /opt/jumpserver/apps/locale/ja /opt/jumpserver/apps/locale/jz
