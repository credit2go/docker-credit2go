#!/usr/bin/env groovy

def label = "builder-${UUID.randomUUID().toString()}"
podTemplate(label: label, yaml: libraryResource('kubernetes/builder.yaml')) {
    node(label) {
        container('slave') {
            checkout scm
            //use clair to do security check
            dockerUtil.clairscannerFromAnchorImages('anchore_images')
            //use anchore to do security check
            anchore forceAnalyze: true, name: 'anchore_images'
        }
    }
}