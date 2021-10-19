import fs from 'fs'
import path from 'path'
import { DockerComposeEnvironment, StartedDockerComposeEnvironment, Wait } from 'testcontainers'
import { generateChecksum } from '../utils/generate-checksum'

jest.setTimeout(10000000)

const VSFTPD_CONTAINER_NAME = 'vsftpd'
const FTP_CLIENT_CONTAINER_NAME = 'test-upload-ftp-client'

const VSFTPD_READY_MESSAGE = 'Running vsftpd'
const FTP_CLIENT_READY_MESSAGE = '221 Goodbye.'

const DOCKER_COMPOSE_TEST_FILE = 'upload-docker-compose.test.yml'

const ENV_LAUNCH_SCRIPT = 'LAUNCH_SCRIPT_LOCAL_FILE'
const ENV_CENTOS_FTP_IMAGE_REPOSITORY = 'CENTOS_FTP_IMAGE_REPOSITORY'
const ENV_CENTOS_FTP_IMAGE_REPOSITORY_TAG = 'CENTOS_FTP_IMAGE_REPOSITORY_TAG'

const CURRENT_DIR = 'upload-docker-image'
const VOLUME_DIR = './volume-files'
const TEST_FILENAME = 'testfile.txt'
const UPLOAD_SCRIPT_PATH = 'upload.sh'

const CENTOS_FTP_IMAGE_REPOSITORY = process.env.CENTOS_FTP_IMAGE_REPOSITORY
const CENTOS_FTP_IMAGE_REPOSITORY_TAG = process.env.CENTOS_FTP_IMAGE_REPOSITORY_TAG

describe('Uploading files', () => {
  let environment: StartedDockerComposeEnvironment

  beforeAll(async () => {
    console.log(process.env)
    console.log('Repo', CENTOS_FTP_IMAGE_REPOSITORY)
    console.log('Tag', CENTOS_FTP_IMAGE_REPOSITORY_TAG)
    const composeFilePath = path.resolve(__dirname)
    const composeFile = DOCKER_COMPOSE_TEST_FILE
    console.log(`Launching from ${composeFilePath}/${composeFile}`)

    environment = await new DockerComposeEnvironment(composeFilePath, composeFile)
      .withWaitStrategy(VSFTPD_CONTAINER_NAME, Wait.forLogMessage(VSFTPD_READY_MESSAGE))
      .withWaitStrategy(FTP_CLIENT_CONTAINER_NAME, Wait.forLogMessage(FTP_CLIENT_READY_MESSAGE))
      .withEnv(ENV_LAUNCH_SCRIPT, UPLOAD_SCRIPT_PATH)
      .withEnv(ENV_CENTOS_FTP_IMAGE_REPOSITORY, CENTOS_FTP_IMAGE_REPOSITORY ?? 'bonjour')
      .withEnv(ENV_CENTOS_FTP_IMAGE_REPOSITORY_TAG, CENTOS_FTP_IMAGE_REPOSITORY_TAG ?? 'bonjour')
      .withBuild()
      .up()

    console.log(`Testcontainers started from ${composeFilePath}/${composeFile}`)
  })

  afterAll(async () => {
    console.log(`Stopping testcontainers`)
    await environment.stop()
    console.log(`Testcontainers stopped`)
  })

  it('should upload a file throught FTP via testcontainer', async () => {
    const testfileSourcePath = path.resolve(__dirname, CURRENT_DIR, TEST_FILENAME)
    const testfileUploadPath = path.resolve(__dirname, VOLUME_DIR, TEST_FILENAME)

    const sourceFile = fs.readFileSync(testfileSourcePath)
    const uploadedFile = fs.readFileSync(testfileUploadPath)

    const sourceFileChecksum = generateChecksum(sourceFile)
    const uploadedFileChecksum = generateChecksum(uploadedFile)

    expect(sourceFileChecksum).toBe(uploadedFileChecksum)
  })
})
