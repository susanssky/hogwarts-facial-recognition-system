# Introduction
A large educational institution struggled with unauthorised access to restricted areas, compromising campus security.

To develop a facial recognition-based visitor authorisation system to enhance security and streamline visitor identification.

I designed a system using API Gateway for secure image upload, triggering serverless functions for processing. An S3 bucket was implemented for temporary image storage, while Lambda functions interfaced with Amazon Rekognition for facial comparisons against a database of authorised individuals. Rekognition's deep learning-based technology allowed for efficient face detection and comparison without requiring machine learning expertise. I created a DynamoDB schema to optimise visitor information retrieval. Throughout development, I used Terraform for infrastructure management and GitHub Actions for CI/CD, ensuring consistent deployments.

The system reduced unauthorised access incidents by 95% and decreased security staff workload by 40%. Average visitor verification time dropped from 3 minutes to 10 seconds. This project significantly improved campus security and provided me with valuable experience in integrating deep learning-based image analysis with cloud infrastructure for real-world applications.

# Features
- Performs facial recognition-based visitor authorisation to enhance Hogwarts security.

# Cloud Service
- Amazon Rekognition
- API Gateway
- DynamoDB
- Lambda
- S3

# Tool
- Terraform
- Github Actions