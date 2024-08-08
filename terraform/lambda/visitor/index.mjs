import {
  RekognitionClient,
  SearchFacesByImageCommand,
} from '@aws-sdk/client-rekognition'
import { DynamoDBClient, GetItemCommand } from '@aws-sdk/client-dynamodb'
const dynamodbClient = new DynamoDBClient({ region: 'eu-west-2' })
const rekognitionClient = new RekognitionClient({ region: 'eu-west-2' })
const tableName = process.env.TABLE

export const handler = async (event) => {
  console.log(`event:${JSON.stringify(event)}`)
  const visitorBucket = process.env.BUCKET
  const objectKey = event.queryStringParameters.objectKey

  try {
    const input = {
      CollectionId: process.env.COLLECTION, // required
      Image: {
        S3Object: {
          Bucket: visitorBucket,
          Name: objectKey,
        },
      },
    }
    const command = new SearchFacesByImageCommand(input)
    console.log(`command: ${JSON.stringify(command)}`)
    const response = await rekognitionClient.send(command)
    console.log(`rekognitionClient response:${JSON.stringify(response)}`)
    for (const match of response.FaceMatches) {
      console.log(
        `FaceId: ${match.Face.FaceId}, Confidence: ${match.Face.Confidence}`
      )

      const face = new GetItemCommand({
        TableName: tableName,
        Key: {
          rekognitionId: {
            S: match.Face.FaceId,
          },
        },
      })

      const faceResult = await dynamodbClient.send(face)
      console.log(`faceResult:${JSON.stringify(faceResult)}`)
      if ('Item' in faceResult) {
        console.log(`Person Found: ${JSON.stringify(faceResult.Item)}`)
        return buildResponse(200, {
          Message: 'Success',
          firstName: faceResult?.Item?.firstName.S,
          lastName: faceResult?.Item?.lastName.S,
        })
      }
    }

    console.log('Person could not be recognized.')
    return buildResponse(403, { Message: 'Person Not Found' })
  } catch (error) {
    console.error(error)
    return buildResponse(500, { Message: 'Internal Server Error' })
  }
}

function buildResponse(statusCode, body = null) {
  const response = {
    statusCode,
    headers: {
      'Access-Control-Allow-Headers': '*',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'OPTIONS,GET',
    },
  }
  if (body) {
    response.body = JSON.stringify(body)
  }
  console.log(`final response: ${JSON.stringify(response)}`)
  return response
}
