from django.db.models import F
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import Player, LevelStat
from .serializers import PlayerSerializer


class UploadStatsView(APIView):
    def post(self, request):
        print("=== UploadStatsView POST ===")
        print("Data received keys:", list(request.data.keys()))
        serializer = PlayerSerializer(data=request.data)
        if serializer.is_valid():
            player = serializer.save()
            print("Player saved/updated:", player.id)
            return Response({'status': 'ok'}, status=status.HTTP_200_OK)
        else:
            print("Serializer invalid:", serializer.errors)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class LeaderboardView(APIView):
    def get(self, request):
        print("=== LeaderboardView GET ===")
        lvl = request.query_params.get('level_id')
        if not lvl:
            print("level_id not provided")
            return Response({'detail': 'level_id required'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            lvl = int(lvl)
        except ValueError:
            print("level_id is not an integer:", lvl)
            return Response({'detail': 'level_id must be int'}, status=status.HTTP_400_BAD_REQUEST)

        print(f"Leaderboard requested for level {lvl}")
        stats_qs = LevelStat.objects.filter(lvl_id=lvl).select_related('player')
        stats = stats_qs.order_by('best_time').all()

        result = []
        for s in stats:
            result.append({
                'player_id': s.player.id,
                'name': s.player.name,
                'coins': s.coins,
                'best_time': s.best_time,
                'attempts': s.attempts
            })

        print(f"✔ Leaderboard produced {len(result)} entries")
        return Response(result, status=status.HTTP_200_OK)
