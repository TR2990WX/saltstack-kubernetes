# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import velero with context %}

velero-backup-secret:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/velero
    - name: /srv/kubernetes/manifests/velero/secrets.yaml
    - source: salt://{{ tpldir }}/templates/secrets.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/velero/secrets.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/velero/secrets.yaml

/opt/velero-linux-amd64-v{{ velero.version }}:
  archive.extracted:
    - source: https://github.com/vmware-tanzu/velero/releases/download/v{{ velero.version }}/velero-v{{ velero.version }}-linux-amd64.tar.gz
    - source_hash: {{ velero.source_hash }}
    - archive_format: tar
    - enforce_toplevel: True
    - if_missing: /opt/velero-linux-amd64-v{{ velero.version }}

/usr/local/bin/velero:
  file.symlink:
    - target: /opt/velero-linux-amd64-v{{ velero.version }}/velero-v{{ velero.version }}-linux-amd64/velero

velero-crds:
  cmd.run:
    - runas: root
    - watch:
      - cmd: velero-fetch-charts
    - cwd: /srv/kubernetes/manifests/velero/velero
    - name: |
        kubectl apply -f crds/

velero-wait-api:
  http.wait_for_successful_query:
    - name: 'http://localhost:8080/apis/velero.io/v1/'
    - match: VolumeSnapshotLocation
    - wait_for: 60
    - request_interval: 5
    - status: 200

velero:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/velero/values.yaml
      - cmd: velero-namespace
      - cmd: velero-fetch-charts
      - http: velero-wait-api
    - cwd: /srv/kubernetes/manifests/velero/velero
    - name: |
        helm upgrade --install velero --namespace velero \
          --values /srv/kubernetes/manifests/velero/values.yaml \
          "./" --wait --timeout 3m