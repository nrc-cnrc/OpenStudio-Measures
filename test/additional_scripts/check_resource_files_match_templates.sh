#!/bin/bash
source ../../env.sh

# Generate a list of the measures.
measures=(`ls -1 ../../measures`)

# Loop through measures and check that the Helper files match the template ones.
for measure in "${measures[@]}";
do
  echo " *************************** "${measure}" *************************** "
  case ${measure} in
    "nrc_report_"*)
      diff ../../measures/${measure}/resources/NRCReportingMeasureHelper.rb ../../measures_templates/NrcTemplateReportingMeasure/resources/NRCReportingMeasureHelper.rb
      diff ../../measures/${measure}/resources/BTAPMeasureHelper.rb ../../measures_templates/NrcTemplateReportingMeasure/resources/BTAPMeasureHelper.rb
	  ;;
	*)
      diff ../../measures/${measure}/resources/NRCMeasureHelper.rb ../../measures_templates/NrcTemplateMeasure/resources/NRCMeasureHelper.rb
      diff ../../measures/${measure}/resources/BTAPMeasureHelper.rb ../../measures_templates/NrcTemplateMeasure/resources/BTAPMeasureHelper.rb
	  ;;
  esac
done
