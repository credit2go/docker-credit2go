#!/usr/bin/env groovy

def label = "builder-${UUID.randomUUID().toString()}"
podTemplate(label: label, yaml: libraryResource('kubernetes/builder.yaml')) {
    node(label) {
        container('slave') {
            checkout scm
            //use anchore to do security check
            anchore forceAnalyze: true, name: 'anchore_images'
            //use clair to do security check
        }
    }
}