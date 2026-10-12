export type StoredObject = {
  key: string;
  url: string;
  contentType: string;
  size: number;
};

export type UploadParams = {
  buffer: Buffer;
  filename: string;
  contentType: string;
  folder?: string;
};

export interface StorageProvider {
  upload(params: UploadParams): Promise<StoredObject>;
  delete(key: string): Promise<void>;
  getUrl(key: string): string;
}
