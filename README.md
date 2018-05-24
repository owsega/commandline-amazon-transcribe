# commandline-amazon-transcribe  (WIP)
A Command Line Utility for transcribing audio recordings using Amazon Transcribe.

The bash script depends on a few other utils including
 - `arecord` for recording
 - `jq` for json parsing
 - `aws` for access to Amazon S3 and Transcribe services
 - other commands include `curl`, `date`, `grep`, etc.
 
### Setup:
 - Install jq, aws, arecord, curl, etc. if they are not yet installed.
 - Setup AWS requirements:
    - create an S3 bucket to store the recordings
    - create a suitable IAM user with permissions for performing tasks on S3 and Transcribe
    - Grant access to that user on the S3 bucket and also
    - configure your aws cli with the IAM user
 - edit `autotranscribe.sh` to set up the recording times, aws region, bucket name, etc.
 
To execute the script run `sh autotranscribe.sh`
