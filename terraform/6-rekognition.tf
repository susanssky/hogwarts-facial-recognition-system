resource "aws_rekognition_collection" "rekognition_collection" {
  collection_id = local.rekognition_collection_id

  tags = {
    name = "build-${local.project_name}"
  }
}
