import { DynamoDBClient, PutItemCommand } from '@aws-sdk/client-dynamodb'
import {
  RekognitionClient,
  IndexFacesCommand,
} from '@aws-sdk/client-rekognition'

const dynamodbClient = new DynamoDBClient({ region: 'eu-west-2' })
const rekognitionClient = new RekognitionClient({ region: 'eu-west-2' })
const tableName = process.env.TABLE

export const handler = async (event) => {
  console.log(JSON.stringify(event))

  const { name: bucketName } = event.Records[0].s3.bucket
  const { key: fileName } = event.Records[0].s3.object
  try {
    const result = await indexFace(bucketName, fileName)

    if (result.$metadata.httpStatusCode === 200) {
      const faceId = result.FaceRecords[0].Face.FaceId
      const category = fileName?.split('/')[0]
      const [firstName, lastName] = fileName
        ?.split('/')[1]
        ?.split('.')[0]
        ?.split('_')
        .concat('')
      console.log(JSON.stringify([firstName, lastName]))
      return await register(faceId, category, firstName, lastName)
    }
  } catch (error) {
    console.log(error)
  }
}
async function indexFace(bucketName, fileName) {
  const input = {
    CollectionId: process.env.COLLECTION,
    Image: {
      S3Object: {
        Bucket: bucketName,
        Name: fileName,
      },
    },
  }
  const command = new IndexFacesCommand(input)
  const response = await rekognitionClient.send(command)
  console.log(`rekognitionClient: ${JSON.stringify(response)}`)
  return response
}
async function register(faceId, category, firstName, lastName = '') {
  let params = {
    TableName: tableName,
    Item: {
      rekognitionId: {
        S: faceId,
      },
      category: {
        S: category,
      },
      firstName: {
        S: firstName,
      },
      lastName: {
        S: lastName,
      },
      createTimestamp: {
        S: new Date().toLocaleString('en-GB'),
      },
    },
  }

  const command = new PutItemCommand(params)
  return await dynamodbClient.send(command)
}
