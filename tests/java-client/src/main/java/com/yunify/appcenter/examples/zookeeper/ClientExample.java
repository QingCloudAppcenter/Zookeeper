package com.yunify.appcenter.examples.zookeeper;

import org.apache.curator.framework.CuratorFramework;
import org.apache.curator.framework.CuratorFrameworkFactory;
import org.apache.curator.retry.ExponentialBackoffRetry;
import org.apache.zookeeper.CreateMode;

import java.util.Arrays;

public class ClientExample {
    public static void main(String[] args) throws Exception {
        String host = "192.168.2.62";
        int port = 2181;
        String connString = String.format("%s:%s", host, port);

        String username = "super";
        String password = "super123";
        String authString = String.format("%s:%s", username, password);

        String scheme = "digest";

        CuratorFrameworkFactory.Builder builder = CuratorFrameworkFactory.builder()
                .connectString(connString)
                .retryPolicy(new ExponentialBackoffRetry(1000, 3));
        CuratorFramework client = builder.build();
        client.start();

        char[] chars = new char[1000000];
        Arrays.fill(chars, 'a');
        String bigStr = new String(chars);
        byte[] value = bigStr.getBytes();
        while (true) {
            String key = String.format("/k%d", System.currentTimeMillis());
            client.create().withMode(CreateMode.PERSISTENT).forPath(key, value);
        }
    }
}
