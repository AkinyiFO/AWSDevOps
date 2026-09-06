cat << EOF > retail-store-ecs-order-taskdef.json
{
    "family": "retail-store-ecs-orders",
    "executionRoleArn": "arn:aws:iam::${ACCOUNT_ID}:role/ordersEcsTaskExecutionRole",
    "taskRoleArn": "arn:aws:iam::${ACCOUNT_ID}:role/retailStoreEcsTaskRole",
    "networkMode": "awsvpc",
    "requiresCompatibilities": [
        "FARGATE"
    ],
    "cpu": "1024",
    "memory": "2048",
    "runtimePlatform": {
        "cpuArchitecture": "X86_64",
        "operatingSystemFamily": "LINUX"
    },
    "containerDefinitions": [
        {
            "name": "application",
            "image": "public.ecr.aws/aws-containers/retail-store-sample-orders:1.2.3",
            "cpu": 0,
            "portMappings": [
                {
                    "name": "application",
                    "containerPort": 8080,
                    "hostPort": 8080,
                    "protocol": "tcp",
                    "appProtocol": "http"
                }
            ],
            "essential": true,
            "linuxParameters": {
                "initProcessEnabled": true
            },
            "healthCheck": {
                "command": [
                    "CMD-SHELL",
                    "curl -f http://localhost:8080/actuator/health || exit 1"
                ],
                "interval": 10,
                "timeout": 5,
                "retries": 3,
                "startPeriod": 30
            },
            "versionConsistency": "disabled",
            "environment": [
                {
                    "name": "RETAIL_ORDERS_PERSISTENCE_PROVIDER",
                    "value": "postgres"
                },
                {
                    "name": "RETAIL_ORDERS_MESSAGING_PROVIDER",
                    "value": "in-memory"
                }
            ],
            "secrets": [
                {
                    "name": "RETAIL_ORDERS_PERSISTENCE_ENDPOINT",
                    "valueFrom": "arn:aws:ssm:${AWS_REGION}:${ACCOUNT_ID}:parameter/retail-store-ecs/orders/db-endpoint-postgres"
                },
                {
                    "name": "RETAIL_ORDERS_PERSISTENCE_NAME",
                    "valueFrom": "arn:aws:secretsmanager:${AWS_REGION}:${ACCOUNT_ID}:secret:retail-store-ecs-orders-db:dbname::"
                },
                {
                    "name": "RETAIL_ORDERS_PERSISTENCE_USERNAME",
                    "valueFrom": "arn:aws:secretsmanager:${AWS_REGION}:${ACCOUNT_ID}:secret:retail-store-ecs-orders-db:username::"
                },
                {
                    "name": "RETAIL_ORDERS_PERSISTENCE_PASSWORD",
                    "valueFrom": "arn:aws:secretsmanager:${AWS_REGION}:${ACCOUNT_ID}:secret:retail-store-ecs-orders-db:password::"
                }
            ],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "retail-store-ecs-tasks",
                    "awslogs-region": "$AWS_REGION",
                    "awslogs-stream-prefix": "orders-service"
                }
            }
        }
    ]
}
EOF

aws ecs register-task-definition --cli-input-json file://retail-store-ecs-order-taskdef.json

aws ecs create-service \
    --cluster retail-store-ecs-cluster \
    --service-name orders \
    --task-definition retail-store-ecs-orders \
    --desired-count 1 \
    --launch-type FARGATE \
    --health-check-grace-period-seconds 30 \
    --enable-execute-command \
    --network-configuration "awsvpcConfiguration={subnets=[${PRIVATE_SUBNET1}, ${PRIVATE_SUBNET2}], securityGroups=[$ORDERS_SG_ID],assignPublicIp=DISABLED}" \
    --service-connect-configuration '{
        "enabled": true,
        "namespace": "retailstore.local",
        "services": [
            {
                "portName": "application",
                "discoveryName": "orders",
                "clientAliases": [
                    {
                        "port": 80,
                        "dnsName": "orders"
                    }
                ]
            }
        ]
    }'

cat << EOF > retail-store-ecs-checkout-taskdef.json
{
    "family": "retail-store-ecs-checkout",
    "executionRoleArn": "arn:aws:iam::${ACCOUNT_ID}:role/checkoutEcsTaskExecutionRole",
    "taskRoleArn": "arn:aws:iam::${ACCOUNT_ID}:role/retailStoreEcsTaskRole",
    "networkMode": "awsvpc",
    "requiresCompatibilities": [
        "FARGATE"
    ],
    "cpu": "1024",
    "memory": "2048",
    "runtimePlatform": {
        "cpuArchitecture": "X86_64",
        "operatingSystemFamily": "LINUX"
    },
    "containerDefinitions": [
        {
            "name": "application",
            "image": "public.ecr.aws/aws-containers/retail-store-sample-checkout:1.2.3",
            "portMappings": [
                {
                    "name": "application",
                    "containerPort": 8080,
                    "hostPort": 8080,
                    "protocol": "tcp",
                    "appProtocol": "http"
                }
            ],
            "essential": true,
            "linuxParameters": {
                "initProcessEnabled": true
            },
            "environment": [
                {
                    "name": "RETAIL_CHECKOUT_PERSISTENCE_PROVIDER",
                    "value": "redis"
                },
                 {
                    "name": "RETAIL_CHECKOUT_ENDPOINTS_ORDERS",
                    "value": "http://orders"
                }
            ],
            "secrets": [
                {
                    "name": "RETAIL_CHECKOUT_PERSISTENCE_REDIS_URL",
                    "valueFrom": "arn:aws:ssm:${AWS_REGION}:${ACCOUNT_ID}:parameter/retail-store-ecs/checkout/redis-endpoint"
                }
            ],
            "healthCheck": {
                "command": [
                    "CMD-SHELL",
                    "curl -f http://localhost:8080/health || exit 1"
                ],
                "interval": 10,
                "timeout": 5,
                "retries": 3,
                "startPeriod": 30
            },
            "versionConsistency": "disabled",
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "retail-store-ecs-tasks",
                    "awslogs-region": "$AWS_REGION",
                    "awslogs-stream-prefix": "checkout-service"
                }
            }
        }
    ]
}
EOF

aws ecs register-task-definition --cli-input-json file://retail-store-ecs-checkout-taskdef.json

aws ecs create-service \
    --cluster retail-store-ecs-cluster \
    --service-name checkout \
    --task-definition retail-store-ecs-checkout \
    --desired-count 1 \
    --launch-type FARGATE \
    --health-check-grace-period-seconds 30 \
    --enable-execute-command \
    --network-configuration "awsvpcConfiguration={subnets=[${PRIVATE_SUBNET1}, ${PRIVATE_SUBNET2}], securityGroups=[$CHECKOUT_SG_ID],assignPublicIp=DISABLED}" \
    --service-connect-configuration '{
        "enabled": true,
        "namespace": "retailstore.local",
        "services": [
            {
                "portName": "application",
                "discoveryName": "checkout",
                "clientAliases": [
                    {
                        "port": 80,
                        "dnsName": "checkout"
                    }
                ]
            }
        ]
    }'

cat << EOF > retail-store-ecs-catalog-taskdef.json
{
    "family": "retail-store-ecs-catalog",
    "executionRoleArn": "arn:aws:iam::${ACCOUNT_ID}:role/catalogEcsTaskExecutionRole",
    "taskRoleArn": "arn:aws:iam::${ACCOUNT_ID}:role/retailStoreEcsTaskRole",
    "networkMode": "awsvpc",
    "requiresCompatibilities": [
        "FARGATE"
    ],
    "cpu": "1024",
    "memory": "2048",
    "runtimePlatform": {
        "cpuArchitecture": "X86_64",
        "operatingSystemFamily": "LINUX"
    },
    "containerDefinitions": [
        {
            "name": "application",
            "image": "public.ecr.aws/aws-containers/retail-store-sample-catalog:1.2.3",
            "portMappings": [
                {
                    "name": "application",
                    "containerPort": 8080,
                    "hostPort": 8080,
                    "protocol": "tcp",
                    "appProtocol": "http"
                }
            ],
            "essential": true,
            "linuxParameters": {
                "initProcessEnabled": true
            },
            "environment": [
                {
                    "name": "RETAIL_CATALOG_PERSISTENCE_DB_NAME",
                    "value": "catalog"
                },
                {
                    "name": "RETAIL_CATALOG_PERSISTENCE_PROVIDER",
                    "value": "mysql"
                }
            ],
            "secrets": [
                {
                    "name": "RETAIL_CATALOG_PERSISTENCE_ENDPOINT",
                    "valueFrom": "arn:aws:ssm:${AWS_REGION}:${ACCOUNT_ID}:parameter/retail-store-ecs/catalog/db-endpoint-mysql"
                },
                {
                    "name": "RETAIL_CATALOG_PERSISTENCE_PASSWORD",
                    "valueFrom": "arn:aws:secretsmanager:${AWS_REGION}:${ACCOUNT_ID}:secret:retail-store-ecs-catalog-db:password::"
                },
                {
                    "name": "RETAIL_CATALOG_PERSISTENCE_USER",
                    "valueFrom": "arn:aws:secretsmanager:${AWS_REGION}:${ACCOUNT_ID}:secret:retail-store-ecs-catalog-db:username::"
                }
            ],
            "versionConsistency": "disabled",
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "retail-store-ecs-tasks",
                    "awslogs-region": "${AWS_REGION}",
                    "awslogs-stream-prefix": "catalog-service"
                }
            },
            "healthCheck": {
                "command": [
                    "CMD-SHELL",
                    "curl -f http://localhost:8080/health || exit 1"
                ],
                "interval": 10,
                "timeout": 5,
                "retries": 3,
                "startPeriod": 30
            }
        }
    ]
}
EOF

aws ecs register-task-definition --cli-input-json file://retail-store-ecs-catalog-taskdef.json

aws ecs create-service \
    --cluster retail-store-ecs-cluster \
    --service-name catalog \
    --task-definition retail-store-ecs-catalog \
    --desired-count 2 \
    --launch-type FARGATE \
    --health-check-grace-period-seconds 30 \
    --enable-execute-command \
    --network-configuration "awsvpcConfiguration={subnets=[${PRIVATE_SUBNET1}, ${PRIVATE_SUBNET2}], securityGroups=[$CATALOG_SG_ID],assignPublicIp=DISABLED}" \
    --service-connect-configuration '{
        "enabled": true,
        "namespace": "retailstore.local",
        "services": [
            {
                "portName": "application",
                "discoveryName": "catalog",
                "clientAliases": [
                    {
                        "port": 80,
                        "dnsName": "catalog"
                    }
                ]
            }
        ]
    }'

# Create retail-store-ecs-ui-connect-taskdef.json
# In it, update the UI service to use the new service connect namespace and discovery names for the backend services
"environment": [
    {
        "name": "RETAIL_UI_ENDPOINTS_ORDERS",
        "value": "http://orders"
    },
    {
        "name": "RETAIL_UI_ENDPOINTS_CHECKOUT",
        "value": "http://checkout"
    },
    {
        "name": "RETAIL_UI_ENDPOINTS_CATALOG",
        "value": "http://catalog"
    }
] 

# Then
aws ecs update-service \
    --cluster retail-store-ecs-cluster \
    --service ui \
    --task-definition retail-store-ecs-ui \
    --force-new-deployment \
    --desired-count 2 \
    --service-connect-configuration '{
        "enabled": true,
        "namespace": "retailstore.local",
        "services": [
            {
                "portName": "application",
                "discoveryName": "ui",
                "clientAliases": [
                    {
                        "port": 80,
                        "dnsName": "ui"
                    }
                ]
            }
        ]
    }'

echo_y "Waiting for service to stabilize..."

aws ecs wait services-stable --cluster retail-store-ecs-cluster --services ui