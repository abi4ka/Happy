import json
import random

from django.db.models import F
from django.http import JsonResponse
from django.views import View
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status

from happyapp.models import Player, LevelStat
from happyapp.serializers import PlayerSerializer

class CoinPosView(View):
    def get(self, request):
        try:
            max_number = int(request.GET.get("max"))
            count = int(request.GET.get("count"))
        except:
            return JsonResponse({"error": "Invalid parameters"}, status=400)

        if max_number < 1 or count < 1:
            return JsonResponse({"error": "Numbers must be positive"}, status=400)

        if count > max_number:
            return JsonResponse({"error": "Count cannot exceed max"}, status=400)

        result = random.sample(range(1, max_number + 1), count)

        return JsonResponse({"result": result})

class UploadStatsView(APIView):
    def post(self, request):
        print("=== UploadStatsView POST ===")
        data = request.data

        player_id = data.get("id")

        if player_id:
            try:
                instance = Player.objects.get(id=player_id)
                serializer = PlayerSerializer(instance, data=data, partial=True)
            except Player.DoesNotExist:
                serializer = PlayerSerializer(data=data)
        else:
            serializer = PlayerSerializer(data=data)

        if serializer.is_valid():
            player = serializer.save()
            print("Player saved/updated:", player.id)
            return Response({'status': 'ok'}, status=status.HTTP_200_OK)

        print("Serializer invalid:", serializer.errors)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class LeaderboardView(APIView):
    def get(self, request):
        print("=== LeaderboardView GET ===")

        level_id = request.query_params.get('level_id')
        exclude_id = request.query_params.get('id')

        return self._get_leaderboard(level_id, exclude_id)

    def post(self, request):
        print("=== LeaderboardView POST ===")

        level_id = request.data.get('level_id')
        exclude_id = request.data.get('id')

        return self._get_leaderboard(level_id, exclude_id)

    def _get_leaderboard(self, level_id, exclude_id):

        if level_id:
            try:
                level_id = int(level_id)
            except ValueError:
                return Response({'detail': 'level_id must be int'}, status=status.HTTP_400_BAD_REQUEST)

            print(f"Leaderboard requested for level {level_id}")
            stats_qs = LevelStat.objects.filter(lvl_id=level_id).select_related('player')
        else:
            print("Leaderboard requested for ALL levels")
            stats_qs = LevelStat.objects.select_related('player').all()

        if exclude_id:
            print(f"Excluding player id: {exclude_id}")
            stats_qs = stats_qs.exclude(player__id=exclude_id)

        stats_qs = stats_qs.order_by('player__id', 'lvl_id')

        players = {}

        for stat in stats_qs:
            pid = stat.player.id

            if pid not in players:
                players[pid] = {
                    "id": stat.player.id,
                    "name": stat.player.name,
                    "levels": []
                }

            players[pid]["levels"].append({
                "lvl_id": stat.lvl_id,
                "attempts": stat.attempts,
                "best_time": stat.best_time,
                "coins": stat.coins
            })

        result = list(players.values())

        print(f"Leaderboard produced {len(result)} player entries")
        return Response(result, status=status.HTTP_200_OK)
