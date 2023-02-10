#!/bin/bash
source ../../env.sh

# Generate a list of the measures.
measures=(`ls -1 ../../measures`)

# Loop through measures and copy the Helper files from the templates.
for measure in "${measures[@]}";
do
  echo " *************************** "${measure}" *************************** "
  case ${measure} in
    "nrc_report_"*)
	  cp ../../measures_templates/NrcTemplateReportingMeasure/resources/NRCReportingMeasureHelper.rb ../../measures/${measure}/resources/
	  cp ../../measures_templates/NrcTemplateReportingMeasure/resources/BTAPMeasureHelper.rb ../../measures/${measure}/resources/
	  ;;
	*)
	  cp ../../measures_templates/NrcTemplateMeasure/resources/NRCMeasureHelper.rb ../../measures/${measure}/resources/
	  cp ../../measures_templates/NrcTemplateMeasure/resources/BTAPMeasureHelper.rb ../../measures/${measure}/resources/
	  ;;
  esac
done
