import { useState, ChangeEvent, FormEvent } from 'react'
import { v4 as uuidv4 } from 'uuid'
import defaultImg from './assets/placeholder.svg'

import './App.css'
const apiUrl = import.meta.env.VITE_API
const bucketName = import.meta.env.VITE_BUCKET

function App() {
  const [image, setImage] = useState<File | null>(null)
  const [resultMsg, setResultMsg] = useState<string>('')
  const [visitorImg, setVisitorImg] = useState<string>(defaultImg)

  const handleImageChange = (e: ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file) {
      setImage(file)
      setResultMsg('Please click the authenticate button.')
      setVisitorImg(URL.createObjectURL(file))
    }
  }

  const sendImage = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    if (!image) return

    const visitorImageName = uuidv4()
    try {
      // Upload the image to 'visitor-s3' bucket
      await fetch(`${apiUrl}/${bucketName}/${visitorImageName}.jpg`, {
        method: 'PUT',
        headers: { 'Content-Type': 'image/jpeg' },
        body: image,
      })

      const response = await authenticate(visitorImageName)

      if (response.Message === 'Success') {
        setResultMsg(`Hi ${response.firstName} ${response.lastName}, welcome!`)
      } else {
        setResultMsg(
          'Authentication Failed: this person is not an employee/a student.'
        )
      }
    } catch (error) {
      setResultMsg(
        'There was an error during the authentication process. Please try again.'
      )
      console.error(error)
    }
  }
  const authenticate = async (
    visitorImageName: string
  ): Promise<AuthResponse> => {
    // requestUrl = `${apiUrl}/hogwarts/?objectKey=${visitorImageName}.jpg`,
    const requestUrl = `${apiUrl}/hogwarts/?${new URLSearchParams({
      objectKey: `${visitorImageName}.jpg`,
    })}`

    const response = await fetch(requestUrl, {
      method: 'GET',
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
      },
    })
    return response.json()
  }

  return (
    <>
      <h2>Hogwarts Facial Recognition System</h2>
      <div className='card'>
        <form onSubmit={sendImage}>
          <input type='file' accept='image/jpeg' onChange={handleImageChange} />
          <button type='submit' disabled={!image}>
            Authenticate
          </button>
        </form>
        <p>{resultMsg}</p>
        <img src={visitorImg} alt='Visitor' style={{ maxWidth: '50%' }} />
      </div>
    </>
  )
}

export default App
