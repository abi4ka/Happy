from rest_framework import serializers
from .models import Player, LevelStat

class LevelStatSerializer(serializers.ModelSerializer):
    class Meta:
        model = LevelStat
        fields = ('lvl_id', 'attempts', 'best_time', 'coins')

class PlayerSerializer(serializers.ModelSerializer):
    levels = LevelStatSerializer(many=True)

    class Meta:
        model = Player
        fields = ('id', 'name', 'levels')

    def create(self, validated_data):
        levels_data = validated_data.pop('levels', [])
        player, created = Player.objects.update_or_create(
            id=validated_data['id'],
            defaults={'name': validated_data.get('name', '')}
        )
        for lvl in levels_data:
            LevelStat.objects.update_or_create(
                player=player, lvl_id=int(lvl['lvl_id']),
                defaults={
                    'attempts': int(lvl.get('attempts', 0)),
                    'best_time': lvl.get('best_time', None),
                    'coins': int(lvl.get('coins', 0)),
                }
            )
        return player
