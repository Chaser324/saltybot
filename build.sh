#!/bin/bash

PATH=$PATH:`npm bin`

coffee -bc scraper
coffee -bc server