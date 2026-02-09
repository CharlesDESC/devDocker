#!/bin/bash

# Script pour nettoyer les ressources AWS orphelines

echo "🧹 Nettoyage des ressources AWS..."

# Région AWS
REGION="eu-west-3"

# 1. Supprimer les anciennes clés SSH
echo "🔑 Suppression des clés SSH orphelines..."
aws ec2 describe-key-pairs --region $REGION --query 'KeyPairs[?starts_with(KeyName, `devdocker`)].KeyName' --output text | while read key; do
    if [ ! -z "$key" ]; then
        echo "  Suppression de la clé: $key"
        aws ec2 delete-key-pair --region $REGION --key-name "$key"
    fi
done

# 2. Supprimer les anciens security groups
echo "🛡️  Suppression des security groups orphelins..."
aws ec2 describe-security-groups --region $REGION --filters "Name=group-name,Values=devdocker*" --query 'SecurityGroups[].GroupId' --output text | while read sg; do
    if [ ! -z "$sg" ]; then
        echo "  Suppression du security group: $sg"
        aws ec2 delete-security-group --region $REGION --group-id "$sg" 2>/dev/null || echo "  ⚠️  Impossible de supprimer $sg (peut-être en cours d'utilisation)"
    fi
done

# 3. Lister les instances EC2 actives
echo "💻 Instances EC2 actives:"
aws ec2 describe-instances --region $REGION --filters "Name=tag:Name,Values=DevDocker*" "Name=instance-state-name,Values=running,pending,stopping,stopped" --query 'Reservations[].Instances[].[InstanceId,State.Name,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' --output table

echo ""
echo "✅ Nettoyage terminé!"
echo ""
echo "💡 Pour supprimer complètement l'infrastructure Terraform:"
echo "   cd infra && terraform destroy -auto-approve"
