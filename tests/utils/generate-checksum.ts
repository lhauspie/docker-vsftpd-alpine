import crypto from 'crypto'

export const HASH_MD5 = 'md5'
export const DIGEST_HEX = 'hex'

export const generateChecksum = (data: Buffer, algorithm?: string, encoding?: crypto.BinaryToTextEncoding) => {
  return crypto
    .createHash(algorithm ?? HASH_MD5)
    .update(data)
    .digest(encoding ?? DIGEST_HEX)
}
