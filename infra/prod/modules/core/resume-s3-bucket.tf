resource "aws_s3_bucket" "resume_gagelara" {
  bucket = "resume.gagelara"
}

resource "aws_s3_bucket_policy" "allow_cf_oac" {
  bucket = aws_s3_bucket.resume_gagelara.id
  policy = data.aws_iam_policy_document.s3_policy.json
}
