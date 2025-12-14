package com.outfit.ai.cloth_app.service;

import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.util.UUID;

// S3에 이미지 등록하는 서비스
@Component
public class S3FileUploader {
    private final AmazonS3Client amazonS3Client;

    @Value("${cloud.aws.s3.bucket}")
    private String bucket;

    public S3FileUploader(AmazonS3Client amazonS3Client) {
        this.amazonS3Client = amazonS3Client;
    }

    // 이미지 업로드
    public String upload(MultipartFile multipartFile, UUID userId) {
        if (multipartFile.isEmpty() || multipartFile.getOriginalFilename() == null) {
            throw new IllegalArgumentException("업로드할 파일이 유효하지 않습니다.");
        }

        String s3Key = createS3Key(multipartFile.getOriginalFilename(), userId);

        ObjectMetadata objectMetadata = new ObjectMetadata();
        objectMetadata.setContentLength(multipartFile.getSize());
        objectMetadata.setContentType(multipartFile.getContentType());

        try (InputStream inputStream = multipartFile.getInputStream()) {
            amazonS3Client.putObject(new PutObjectRequest(bucket, s3Key, inputStream, objectMetadata));

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("파일 업로드에 실패했습니다: " + e.getMessage());
        }

        return amazonS3Client.getUrl(bucket, s3Key).toString();
    }

    // S3키 생성, 유저마다 다 다르게 이미지 링크를 생성함
    public String createS3Key(String originalFileName, UUID userId) {
        String ext = originalFileName.substring(originalFileName.lastIndexOf("."));
        return String.format("users/%s/clothes/%s%s",
                userId.toString(),
                UUID.randomUUID().toString(),
                ext);
    }
}
