#!/bin/bash
# A 5-step process to do STT with Amazon Transcribe
# 1. Record audio
# 2. Upload audio to s3
# 3. Use s3 audio to create and start a Transcribe job
# 4. Keep checking Transcribe job till its COMPLETED
# 5. Download Transcribe job results and display
#
# Note: The script has a few dependencies: AWS CLI installed and configured, jq, curl, date

date=`date +%s`
request_ID="transcribe_job_$date"
audio_length=5
aws_s3_bucket="seyi-bucket001"
aws_region="us-east-2"

# 1. Record audio. Max limit of 14 seconds. Amazon has actual 2-hour limit
echo "Recording $audio_length seconds of audio ..."
arecord -d ${audio_length} -f S16_LE speech.wav
echo "Recording stopped"

# 2. Upload audio file to s3
echo "Uploading audio ..."
aws s3 cp speech.wav "s3://$aws_s3_bucket/$request_ID.wav"

# 3. Use s3 audio to create and start a Transcribe job
echo "Starting transcription ..."

echo "{
    \"TranscriptionJobName\": \"$request_ID\",
    \"LanguageCode\": \"en-US\",
    \"MediaFormat\": \"wav\",
    \"Media\": {\"MediaFileUri\": \"https://s3.$aws_region.amazonaws.com/$aws_s3_bucket/$request_ID.wav\"}
}" > request.json
aws transcribe start-transcription-job --region ${aws_region} --cli-input-json file://request.json

# 4. Keep checking Transcribe job till its COMPLETED
echo "Transcription $request_ID in progress ..."
aws transcribe get-transcription-job --region ${aws_region} --transcription-job-name ${request_ID} > response.json
x=1
while [ ${x} -le 2 ]
do
  if grep -Fq "COMPLETED" response.json
  then
      echo "Transcription completed" # code if found
      x=3
  else
      sleep 5  # 5 seconds sleep before trying again
      aws transcribe get-transcription-job --region ${aws_region} --transcription-job-name ${request_ID} > response.json
  fi
done
echo "Transcription done."

# 5. Download Transcribe job results and display
echo "Retrieving Transcript ..."
curl -s `jq -rcM .TranscriptionJob.Transcript.TranscriptFileUri response.json` | jq .results.transcripts[].transcript
